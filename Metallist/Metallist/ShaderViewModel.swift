//
//  ShaderViewModel.swift
//  Metallist
//
//  Created by Oleg Loginov on 24.07.2025.
//


import SwiftUI

class ShaderViewModel: ObservableObject {
    @Published var shaders: [Shader] = []
    @Published var selectedShaderID: Shader.ID?
    
    var currentShader: Shader? {
        shaders.first(where: { $0.id == selectedShaderID })
    }

    init() {
        loadDefaultShaders()
    }

    func loadDefaultShaders() {
        shaders = [
            Shader(name: "CIPixellate", description: "Wavy distortion effect.", parameters: [
                ShaderParameter(name: kCIInputScaleKey, value: 5, range: 1...10),
            ]),
            Shader(name: "CISepiaTone", description: "Applies sepia tone.", parameters: []),
            Shader(name: "CIGaussianBlur", description: "Applies blur to the image.", parameters: []),
            // ...
        ]
        
        let builtIn = CIFilter.filterNames(inCategory: kCICategoryBlur)
        CIFilter.gaussianBlur()

        if let filter = CIFilter(name: "CIGaussianBlur") {
            let displayName = filter.attributes[kCIAttributeFilterDisplayName] as? String ?? filter.name
            print("Описание: \(displayName)")
        }

        let appleShaders = builtIn.compactMap { filterName -> Shader? in
            guard let filter = CIFilter(name: filterName) else { return nil }
            let displayName = filter.attributes[kCIAttributeFilterDisplayName] as? String ?? filterName

            let inputKeys = filter.inputKeys.filter { $0 != kCIInputImageKey }

            let parameters: [ShaderParameter] = inputKeys.compactMap { key in
                guard let attr = filter.attributes[key] as? [String: Any] else { return nil }

                guard let defaultValue = attr[kCIAttributeDefault] as? NSNumber else { return nil }

                let minValue = (attr[kCIAttributeMin] as? NSNumber)?.doubleValue ?? defaultValue.doubleValue - 10
                let maxValue = (attr[kCIAttributeMax] as? NSNumber)?.doubleValue ?? defaultValue.doubleValue + 10

                return ShaderParameter(
                    name: key,
                    value: defaultValue.doubleValue,
                    range: minValue...maxValue
                )
            }

            return Shader(name: filterName, description: displayName, parameters: parameters)
        }

        shaders.append(contentsOf: appleShaders)
    }

    func addShader(_ shader: Shader) {
        shaders.append(shader)
    }
//
//    func updateShader(_ shader: Shader) {
//        if let index = shaders.firstIndex(where: { $0.id == shader.id }) {
//            shaders[index] = shader
//        }
//    }
    
    func updateParameter(for shaderID: Shader.ID, paramID: UUID, newValue: Double) {
           guard let shaderIndex = shaders.firstIndex(where: { $0.id == shaderID }) else { return }
           guard let paramIndex = shaders[shaderIndex].parameters.firstIndex(where: { $0.id == paramID }) else { return }
           shaders[shaderIndex].parameters[paramIndex].value = newValue
       }
}
