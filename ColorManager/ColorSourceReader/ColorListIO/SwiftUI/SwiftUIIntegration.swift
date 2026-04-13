//
//  SwiftUIIntegration.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - SwiftUI Integration

/// SwiftUI view modifier for importing color lists
struct ColorListImporterModifier: ViewModifier
{
    @Binding var isPresented: Bool
    let onImport: (Result<ImportedColorData, ColorListError>) -> Void
    
    func body(content: Content) -> some View
    {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [.xml],
                allowsMultipleSelection: false
            ) { result in
                switch result
                {
                    case .success(let urls):
                        guard let url = urls.first else
                        {
                            onImport(.failure(.fileAccessDenied))
                            return
                        }
                        
                        do
                        {
                            let importedData = try ColorListIO.parseXMLFile(url: url)
                            onImport(.success(importedData))
                        }
                        catch let error as ColorListError
                        {
                            onImport(.failure(error))
                        }
                        catch
                        {
                            onImport(.failure(.parsingFailed(error.localizedDescription)))
                        }
                        
                    case .failure(let error):
                        onImport(.failure(.parsingFailed(error.localizedDescription)))
                }
            }
    }
}

extension View
{
    /// Presents a file importer for color list XML files
    /// - Parameters:
    ///   - isPresented: Binding to control presentation
    ///   - onImport: Closure called with import result
    func colorListImporter(isPresented: Binding<Bool>,
                           onImport: @escaping (Result<ImportedColorData, ColorListError>) -> Void) -> some View
    {
        modifier(ColorListImporterModifier(isPresented: isPresented, onImport: onImport))
    }
}

