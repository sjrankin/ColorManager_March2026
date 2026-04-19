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
#if os(macOS)
       Text("Edit")
#else
            Image(systemName: "pencil")
#endif
        }
        .help("Edit the selected color")
        .toolbarButtonStyle()
    }
    
    var cameraButton: some View
    {
        Button(action: { handleCamera() })
        {
#if os(macOS)
            Text("Camera")
#else
            Image(systemName: "camera")
#endif
        }
        .help("Use the system's camera to match a color")
        .toolbarButtonStyle(prominent: false)
    }
    
    var searchButton: some View
    {
        Button(action: { handleSearch() })
        {
#if os(macOS)
            Text("Search")
#else
            Image(systemName: "magnifyingglass")
#endif
        }
        .help("Search for colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    var filterButton: some View
    {
        Button(action: { handleFilter() })
        {
#if os(macOS)
            Text("Filter")
#else
            Image(systemName: "line.3.horizontal.decrease.circle")
#endif
        }
        .help("Filter colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    var importButton: some View
    {
        Button(action: { handleImport() })
        {
#if os(macOS)
            Text("Import")
#else
            Image(systemName: "square.and.arrow.down")
#endif
        }
        .help("Import colors from a file")
        .toolbarButtonStyle(prominent: false)
    }
    
    var exportButton: some View
    {
        Button(action: { handleExport() })
        {
#if os(macOS)
            Text("Export")
#else
            Image(systemName: "square.and.arrow.up")
#endif
        }
        .help("Export colors to a file")
        .toolbarButtonStyle(prominent: false)
    }
    
    var paletteButton: some View
    {
        Button(action: { handleExport() })
        {
#if os(macOS)
            Text("Palette")
#else
            Image(systemName: "paintpalette")
#endif
        }
        .help("Create a palette and apply it to an image")
        .toolbarButtonStyle(prominent: false)
    }
    
    var createColorButton: some View
    {
        Button(action: { handleExport() })
        {
#if os(macOS)
            Text("Create")
#else
            Image(systemName: "asterisk.circle.fill")
#endif
        }
        .help("Create a color using English or math")
        .toolbarButtonStyle(prominent: false)
    }
    
    var ViewBy: some View
    {
        Picker("", selection: $ViewStyle)
        {
            Image(systemName: "square.grid.2x2")
                .tag(0)
            Image(systemName: "list.bullet")
                .tag(1)
        }
        .pickerStyle(.segmented)
    }
    
#if !os(macOS)
    var structureButton: some View
    {
        Button(action: { ShowStructureNavigator.toggle() })
        {
            Image(systemName: ShowStructureNavigator ? "sidebar.left" : "sidebar.left")
        }
        .help("Show color structure")
        .toolbarButtonStyle(prominent: ShowStructureNavigator)
    }
#endif

    var infoButton: some View
    {
        Button(action: { ShowColorInfo() })
        {
#if os(macOS)
            Text("Color Info")
#else
            Image(systemName: ShowColorInfoPanel ? "info.circle.fill" : "info.circle")
#endif
        }
        .help("Show color information")
        .toolbarButtonStyle(prominent: false)
        .tint(ShowColorInfoPanel ? .accentColor : nil)
    }
}
