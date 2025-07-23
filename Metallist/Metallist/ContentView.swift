//
//  ContentView.swift
//  Metallist
//
//  Created by Oleg Loginov on 16.07.2025.
//

import SwiftUI

struct ShaderParameter: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var value: Double
    let range: ClosedRange<Double>
}

struct Shader: Identifiable, Equatable, Hashable {
    let id = UUID().uuidString
    let name: String
    let description: String
    var parameters: [ShaderParameter]
}

struct ContentView: View {
    @State private var shaders: [Shader] = [
        Shader(name: "CIPixellate", description: "Wavy distortion effect.", parameters: [
            ShaderParameter(name: kCIInputScaleKey, value: 5, range: 1...10),
        ]),
        Shader(name: "CISepiaTone", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIGaussianBlur", description: "Applies blur to the image.", parameters: []),
        Shader(name: "CIBokehBlur", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIBoxBlur", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIColorThreshold", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIComicEffect", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIPhotoEffectNoir", description: "Color channels are shifted.", parameters: []),
        Shader(name: "CIThermal", description: "Color channels are shifted.", parameters: []),
        
    ]
    
    @State private var selectedShaderID: Shader.ID?
    @State private var currentShader: Shader?

    var body: some View {
        HStack(spacing: 0) {
            NavigationSplitView {
                List(shaders, selection: $selectedShaderID) { shader in
                    HStack {
                        Text(shader.name)
                        Spacer()
                        Image(systemName: "apple.logo")
                    }
                }
                .onChange(of: selectedShaderID) { old, newID in
                    if let id = newID {
                        currentShader = shaders.first(where: { $0.id == id })
                    }
                }
                .frame(minWidth: 250)
            } detail: {
                EmptyView()
            }
            .frame(minWidth: 250, maxWidth: 250)
            
            if let id = selectedShaderID {
                if let shader = currentShader {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack {
                                Text("Output")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 4)
                                if let nsImage = NSImage(named: "img") {
                                    Image(nsImage: nsImage.applyFilter(name: shader.name, configure: { filter in
                                        for param in shader.parameters {
                                            filter.setValue(param.value, forKey: param.name)
                                        }
                                    })!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color(NSColor.windowBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .border(Color.gray.opacity(0.2), width: 1)
                                } else {
                                    Text("Image not found")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding()
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ShadersEmptyListPlaceholder()
                }
            } else {
                ShadersEmptyListPlaceholder()
            }
            
            
            if let id = selectedShaderID {
                if let shader = currentShader {
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text(shader.name)
                            .font(.title2)
                        Text(shader.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                        Divider()
                        if shader.parameters.count > 0 {
                            Text("Parameters")
                                .font(.headline)
                            ForEach(shader.parameters) { param in
                                HStack {
                                    Text(param.name)
                                        .frame(width: 100, alignment: .leading)
                                    if let index = currentShader?.parameters.firstIndex(where: { $0.id == param.id }) {
                                        Slider(value: Binding(
                                            get: { currentShader?.parameters[index].value ?? param.value },
                                            set: { newValue in
                                                currentShader?.parameters[index].value = newValue
                                            }
                                        ), in: param.range)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(width: 250)
                    .background(Color(NSColor.controlBackgroundColor))
                }
            }
            
        }
    }

}

struct ShadersEmptyListPlaceholder: View {
    var body: some View {
        Text("Select a shader from the list")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins



extension NSImage {
  
    func applyFilter(_ filter: CIFilter) -> NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: self.size)
    }
    
    func applyFilter(name: String, configure: (CIFilter) -> Void) -> NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData),
              let filter = CIFilter(name: name) else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        configure(filter)

        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: self.size)
    }
    
    func pixelated(scale: Float = 10.0) -> NSImage? {
        let filter = CIFilter(name: "CIPixellate")!
        filter.setValue(scale, forKey: kCIInputScaleKey)
        return applyFilter(filter)
    }
    
    func blurred(radius: Float = 5.0) -> NSImage? {
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        return applyFilter(filter)
    }
    
    func sepia(intensity: Float = 1.0) -> NSImage? {
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        return applyFilter(filter)
    }

}
