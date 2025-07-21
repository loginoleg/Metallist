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
    let imageName: String
    let parameters: [ShaderParameter]
}

struct ContentView: View {
    @State private var shaders: [Shader] = [
        Shader(id: "wave", name: "Wave", description: "Wavy distortion effect.", imageName: "wave", parameters: [
            ShaderParameter(name: "Amplitude", value: 0.5, range: 0.0...1.0),
            ShaderParameter(name: "Frequency", value: 2.0, range: 1.0...5.0)
        ]),
        Shader(id: "blur", name: "Blur", description: "Applies blur to the image.", imageName: "blur", parameters: []),
        Shader(id: "color_shift", name: "Color Shift", description: "Color channels are shifted.", imageName: "colorshift", parameters: [])
    ]
    @State private var selectedShaderID: Shader.ID?

    var body: some View {
        HStack(spacing: 0) {
            NavigationSplitView {
                List(shaders, selection: $selectedShaderID) { shader in
                    Text(shader.name)
                }
                .frame(minWidth: 200)
            } detail: {
                EmptyView()
            }
            .frame(minWidth: 200, maxWidth: 300)
            
            if let id = selectedShaderID,
               let shader = shaders.first(where: { $0.id == id }) {
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack {
                        VStack {
                            Text("Original")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                            shaderImage(for: shader.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(NSColor.windowBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .border(Color.gray.opacity(0.2), width: 1)
                        }
                        VStack {
                            Text("Shader Applied")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                            shaderImage(for: shader.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(NSColor.windowBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .border(Color.gray.opacity(0.2), width: 1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Select a shader from the list")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    /// Returns an image for the shader, or a placeholder if not found.
    private func shaderImage(for imageName: String) -> Image {
        if NSImage(named: imageName) != nil {
            return Image(imageName)
        } else {
            return Image(systemName: "photo")
        }
    }
}
