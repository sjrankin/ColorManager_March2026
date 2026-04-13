//
//  ContentViewButtons.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Toolbar Buttons

extension ContentView
{
    var editButton: some View
    {
        Button(action: { handleEdit() })
        {
            Text("Edit")
        }
        .help("Edit the selected color")
        .toolbarButtonStyle()
    }
    
    var cameraButton: some View
    {
        Button(action: { handleCamera() })
        {
            Image(systemName: "camera")
        }
        .help("Use the system's camera to match a color")
        .toolbarButtonStyle(prominent: false)
    }
    
    var searchButton: some View
    {
        Button(action: { handleSearch() })
        {
            Image(systemName: "magnifyingglass")
        }
        .help("Search for colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    var filterButton: some View
    {
        Button(action: { handleFilter() })
        {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .help("Filter colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    var importButton: some View
    {
        Button(action: { handleImport() })
        {
            Image(systemName: "square.and.arrow.down")
        }
        .help("Import colors from a file")
        .toolbarButtonStyle(prominent: false)
    }
    
    var exportButton: some View
    {
        Button(action: { handleExport() })
        {
            Image(systemName: "square.and.arrow.up")
        }
        .help("Export colors to a file")
        .toolbarButtonStyle(prominent: false)
    }
    
    var paletteButton: some View
    {
        Button(action: { handleExport() })
        {
            Image(systemName: "paintpalette")
        }
        .help("Create a palette and apply it to an image")
        .toolbarButtonStyle(prominent: false)
    }
    
    var createColorButton: some View
    {
        Button(action: { handleExport() })
        {
            Image(systemName: "asterisk.circle.fill")
        }
        .help("Create a color using English or math")
        .toolbarButtonStyle(prominent: false)
    }
    
    var infoButton: some View
    {
        Button(action: { ShowColorInfo() })
        {
            Image(systemName: ShowColorInfoPanel ? "info.circle.fill" : "info.circle")
        }
        .help("Show color information")
        .toolbarButtonStyle(prominent: false)
        .tint(ShowColorInfoPanel ? .accentColor : nil)
    }
}
