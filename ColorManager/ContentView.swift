//
//  ContentView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/20/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ContentView: View
{
    @State var ShowEditor: Bool = false
    @State var SearchColor: Bool = false
    @State var ShowCameraMatchView: Bool = false
    @State var SelectedSwatch: UUID = UUID.empty
    #if os(macOS)
    @State var PaletteBackground: Color = Color(nsColor: NSColor.controlBackgroundColor)
    #else
    @State var PaletteBackground: Color = Color(UIColor.systemGray5)
    #endif
    
    let PaletteColumns = [GridItem(.adaptive(minimum: 90))]
    
    var SwatchSize: CGFloat = 90
    
    // MARK: - Helper Functions
    
    /// Recursively count all colors in a ColorGroup, including nested groups and collections
    private func countColorsInGroup(_ group: ColorGroup) -> Int
    {
        var count = 0
        
        // Count colors directly in this group
        if let colors = group.Colors
        {
            count += colors.count
        }
        
        // Recursively count colors in nested groups
        if let nestedGroups = group.Groups
        {
            for nestedGroup in nestedGroups
            {
                count += countColorsInGroup(nestedGroup)
            }
        }
        
        // Recursively count colors in collections
        if let collections = group.Collections
        {
            for collection in collections
            {
                count += countColorsInCollection(collection)
            }
        }
        
        return count
    }
    
    /// Recursively count all colors in a ColorCollection, including nested collections
    private func countColorsInCollection(_ collection: ColorCollection) -> Int
    {
        var count = 0
        
        // Count colors directly in this collection
        if let colors = collection.Colors
        {
            count += colors.count
        }
        
        // Recursively count colors in nested collections
        if let nestedCollections = collection.Collections
        {
            for nestedCollection in nestedCollections
            {
                count += countColorsInCollection(nestedCollection)
            }
        }
        
        return count
    }
    
    /// Count all colors in the entire Colors structure
    private func countAllColors(_ colors: Colors) -> Int
    {
        guard let groups = colors.ColorGroups else { return 0 }
        return groups.reduce(0) { $0 + countColorsInGroup($1) }
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // Toolbar area with visible background
            HStack(spacing: 8)
            {
                Button(action:
                        {
                })
                {
                    Text("Edit")
                }
                .help("Edit the selected color")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.borderedProminent)
                #endif
                
                Button(action:
                        {
                    ShowCameraMatchView.toggle()
                })
                {
                    Image(systemName: "camera")
                }
                .help("Use the system's camera to match a color")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.bordered)
                #endif
                
                Button(action:
                        {
                    ShowCameraMatchView.toggle()
                })
                {
                    Image(systemName: "magnifyingglass")
                }
                .help("Search for colors")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.bordered)
                #endif
                
                Button(action:
                        {
                    
                })
                {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .help("Filter colors")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.bordered)
                #endif
                .padding(.trailing, 10)
                
                Button(action:
                        {
                    //import
                    ColorListIO.importColorList
                    {
                        result in
                        switch result
                        {
                        case .success(let importedData):
                            // Handle successful import based on import type
                            switch importedData.importType
                                {
                            case .fullStructure:
                                if let fullColors = importedData.fullColors
                                    {
                                    print("Successfully imported full color structure from \(importedData.sourceFileName ?? "unknown")")
                                    let totalColors = countAllColors(fullColors)
                                    let groupCount = fullColors.ColorGroups?.count ?? 0
                                    print("Total colors: \(totalColors) in \(groupCount) top-level groups")
                                }
                            case .groups:
                                if let groups = importedData.colorGroups
                                    {
                                    let totalColors = groups.reduce(0) { $0 + countColorsInGroup($1) }
                                    print("Successfully imported \(groups.count) color groups with \(totalColors) colors")
                                }
                            case .records:
                                if let records = importedData.colorRecords
                                    {
                                    print("Successfully imported \(records.count) color records")
                                }
                            }
                        case .failure(let error):
                            // Handle error
                            print("Import failed: \(error.localizedDescription)")
                        }
                    }
                })
                {
                    Image(systemName: "square.and.arrow.down")
                }
                .help("Import colors from a file")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.bordered)
                #endif
                
                Button(action:
                        {
                    
                })
                {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export colors to a file")
                #if os(macOS)
                .buttonStyle(.bordered)
                .controlSize(.large)
                #else
                .buttonStyle(.bordered)
                #endif
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .systemBackground))
            #endif
            
            Divider()
        }
        ScrollView
        {
            VStack(spacing: 0)
            {
                LazyVGrid(columns: PaletteColumns, spacing: 1.0)
                {
                    SwatchView(SelectedID: $SelectedSwatch,
                                SwatchColor: Color.orange,
                               SwatchColorName: "Dark Orange",
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: Color.red,
                               SwatchColorName: "Ugly Red",
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: Color.accentColor,
                               SwatchColorName: "Accent",
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: Color.pink,
                               SwatchColorName: "Really Dark Pink",
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: TestColor.GetColor(.SystemYellow),
                               SwatchColorName: TestColor.GetColorName(.SystemYellow),
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: TestColor.GetColor(.JapaneseFlagRed),
                               SwatchColorName: TestColor.GetColorName(.JapaneseFlagRed),
                               SwatchWidth: SwatchSize)
                    .padding(4)
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: TestColor.GetColor(.ReallyLongColorName),
                               SwatchColorName: TestColor.GetColorName(.ReallyLongColorName),
                               SwatchWidth: SwatchSize)
                    .padding(4)
                }
                .padding(.horizontal, 8)
                
                // Spacer that fills remaining space and captures taps below content
                Color.clear
                    .frame(minHeight: 100)
                    .contentShape(Rectangle())
                    .onTapGesture
                    {
                        SelectedSwatch = UUID.empty
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            .onTapGesture
            {
                SelectedSwatch = UUID.empty
            }
        }
        .background(PaletteBackground)
    }
}

#Preview
{
    ContentView()
}

extension UUID
{
    static var empty: UUID
    {
        return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}
