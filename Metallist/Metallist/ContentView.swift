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
    let id: String
    let name: String
    let description: String
    let parameters: [ShaderParameter]
}

struct ContentView: View {
    @State private var shaders: [Shader] = [
        Shader(id: "wave", name: "Wave", description: "Wavy distortion effect.", parameters: [
            ShaderParameter(name: "Amplitude", value: 0.5, range: 0.0...1.0),
            ShaderParameter(name: "Frequency", value: 2.0, range: 1.0...5.0)
        ]),
        Shader(id: "blur", name: "Blur", description: "Applies blur to the image.", parameters: []),
        Shader(id: "color_shift", name: "Color Shift", description: "Color channels are shifted.", parameters: [])
    ]
    @State private var selectedShaderID: Shader.ID?

    var body: some View {
        HStack(spacing: 0) {
            NavigationSplitView {
                List(shaders, selection: $selectedShaderID) { shader in
                    Text(shader.name)
                }
                .frame(minWidth: 250)
            } detail: {
                EmptyView()
            }
            .frame(minWidth: 250, maxWidth: 250)
            
            if let id = selectedShaderID,
               let shader = shaders.first(where: { $0.id == id }) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack {
                            Text("Shader Applied")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                            if let nsImage = NSImage(named: "img") {
                                
                                Image(nsImage: nsImage.pixelized())
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
            
            
            if let id = selectedShaderID,
               let shader = shaders.first(where: { $0.id == id }) {
                
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
                                Slider(value: Binding(
                                    get: { param.value },
                                    set: { _ in }
                                ), in: param.range)
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
    func pixelized(scale: Float = 20) -> NSImage {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else {
            return self
        }

        let context = CIContext()
        let filter = CIFilter.pixellate()
        filter.inputImage = ciImage
        filter.scale = scale

        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            let size = NSSize(width: output.extent.width, height: output.extent.height)
            let finalImage = NSImage(cgImage: cgimg, size: size)
            return finalImage
        }

        return self
    }

}

