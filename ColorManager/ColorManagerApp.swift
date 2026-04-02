//
//  ColorManagerApp.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/20/26.
//

import SwiftUI

@main
struct ColorManagerApp: App {
    @StateObject private var colorList = ColorList.shared
    
    init() {
        // Load initial base colors at startup
        loadInitialBaseColors()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(colorList)
        }
    }
    
    /// Load the InitialBaseColors.xml file at app startup
    private func loadInitialBaseColors() {
        // Debug: Print all resources in bundle
        if let resourcePath = Bundle.main.resourcePath {
            print("Bundle resource path: \(resourcePath)")
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                print("Bundle contents: \(contents)")
                let xmlFiles = contents.filter { $0.hasSuffix(".xml") }
                print("XML files found: \(xmlFiles)")
            }
        }
        
        guard let url = Bundle.main.url(forResource: "InitialBaseColors", withExtension: "xml") else {
            print("Error: InitialBaseColors.xml not found in bundle")
            
            // Try alternative search methods
            if let url = Bundle.main.url(forResource: "InitialBaseColors", withExtension: "xml", subdirectory: nil) {
                print("Found in alternative search: \(url)")
                loadFromURL(url)
                return
            }
            
            // Try with different case
            if let url = Bundle.main.url(forResource: "initialbasecolors", withExtension: "xml") {
                print("Found with lowercase: \(url)")
                loadFromURL(url)
                return
            }
            
            return
        }
        
        loadFromURL(url)
    }
    
    /// Load colors from a specific URL
    private func loadFromURL(_ url: URL) {
        do {
            let importedData = try ColorListIO.parseXMLFile(url: url)
            
            // Load the data into ColorList on the main thread
            Task { @MainActor in
                try? colorList.loadFromImportedData(importedData)
                print("Successfully loaded InitialBaseColors.xml from: \(url.lastPathComponent)")
                print("Total colors loaded: \(colorList.totalColorCount())")
            }
        } catch let error as ColorListError {
            print("Error loading InitialBaseColors.xml: \(error.localizedDescription)")
        } catch {
            print("Unexpected error loading InitialBaseColors.xml: \(error.localizedDescription)")
        }
    }
}
