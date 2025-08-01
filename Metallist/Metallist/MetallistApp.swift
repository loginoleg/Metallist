//
//  MetallistApp.swift
//  Metallist
//
//  Created by Oleg Loginov on 16.07.2025.
//

/*
 https://serialcoder.dev/text-tutorials/swiftui/meet-the-inspector-view-in-swiftui/
 */

import SwiftUI
import CoreImage

@main
struct MetallistApp: App {
    
    
    init() {
        let builtIn = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print("builtIn: \(builtIn)")
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
