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
    @EnvironmentObject var colorList: ColorList
    
    @State var ShowEditor: Bool = false
    @State var SearchColor: Bool = false
    @State var ShowCameraMatchView: Bool = false
    @State var SelectedSwatch: UUID = UUID.empty
    @State private var selectedGroupPath: [String] = [] // Track selected group hierarchy
    @State private var expandedGroups: Set<String> = [] // Track expanded groups
    
    #if os(macOS)
    @State var PaletteBackground: Color = Color(nsColor: NSColor.controlBackgroundColor)
    #else
    @State var PaletteBackground: Color = Color(UIColor.systemGray5)
    #endif
    
    // Use flexible columns that maintain consistent spacing
    let PaletteColumns = [
        GridItem(.adaptive(minimum: 90, maximum: 120), spacing: 8)
    ]
    
    var SwatchSize: CGFloat = 90
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            toolbarView
            Divider()
            colorGridView
        }
    }
}

// MARK: - View Components

extension ContentView
{
    /// Toolbar with action buttons
    private var toolbarView: some View
    {
        HStack(spacing: 8)
        {
            editButton
            cameraButton
            searchButton
            filterButton
                .padding(.trailing, 10)
            importButton
            exportButton
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        #if os(macOS)
        .background(Color(nsColor: .controlBackgroundColor))
        #else
        .background(Color(uiColor: .systemBackground))
        #endif
    }
    
    /// Main color grid with scroll view
    private var colorGridView: some View
    {
        HSplitView
        {
            // Left side - Tree structure
            structureNavigator
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 400)
            
            // Right side - Color grid
            colorDisplayArea
                .frame(minWidth: 400)
        }
    }
    
    /// Left side navigation tree
    private var structureNavigator: some View
    {
        VStack(spacing: 0)
        {
            // Header
            HStack
            {
                Text("Structure")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Spacer()
                Button(action: { expandAll() })
                {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                }
                .help("Expand/Collapse All")
                .buttonStyle(.plain)
                .padding(.trailing, 12)
            }
            #if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
            #else
            .background(Color(uiColor: .systemBackground))
            #endif
            
            Divider()
            
            // Tree view
            ScrollView
            {
                VStack(alignment: .leading, spacing: 0)
                {
                    if let groups = colorList.colorGroups, !groups.isEmpty
                    {
                        // "All Colors" option
                        HStack(spacing: 4)
                        {
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundColor(selectedGroupPath.isEmpty ? .accentColor : .secondary)
                                .font(.system(size: 14))
                            
                            Text("All Colors")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedGroupPath.isEmpty ? .primary : .primary)
                            
                            Spacer()
                            
                            Text("\(colorList.totalColorCount())")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(selectedGroupPath.isEmpty ? Color.accentColor.opacity(0.15) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture
                        {
                            selectedGroupPath = []
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Groups
                        ForEach(Array(groups.enumerated()), id: \.element.Name) { index, group in
                            GroupTreeNode(
                                group: group,
                                path: [group.Name],
                                level: 0,
                                expandedGroups: $expandedGroups,
                                selectedGroupPath: $selectedGroupPath
                            )
                        }
                    }
                    else
                    {
                        Text("No structure loaded")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            #if os(macOS)
            .background(Color(nsColor: .textBackgroundColor))
            #else
            .background(Color(uiColor: .systemBackground))
            #endif
        }
    }
    
    /// Right side color display area
    private var colorDisplayArea: some View
    {
        ScrollView
        {
            VStack(spacing: 0)
            {
                colorGrid
                clearSelectionSpacer
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
            .onTapGesture { clearSelection() }
        }
        .background(PaletteBackground)
    }
    
    /// Grid of color swatches
    private var colorGrid: some View
    {
        LazyVGrid(columns: PaletteColumns, spacing: 8)
        {
            let allColors = getAllColors()
            
            if allColors.isEmpty
            {
                emptyStateView
            }
            else
            {
                ForEach(allColors, id: \.id) { colorRecord in
                    SwatchView(
                        SelectedID: $SelectedSwatch,
                        SwatchColor: colorFromRecord(colorRecord),
                        SwatchColorName: colorRecord.Name,
                        SwatchColorValue: valueFromRecord(colorRecord),
                        SwatchWidth: SwatchSize
                    )
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }
    
    /// Empty state when no colors are loaded
    private var emptyStateView: some View
    {
        Text("No colors loaded")
            .foregroundColor(.secondary)
            .padding()
    }
    
    /// Spacer that clears selection when tapped
    private var clearSelectionSpacer: some View
    {
        Color.clear
            .frame(minHeight: 100)
            .contentShape(Rectangle())
            .onTapGesture { clearSelection() }
    }
}

// MARK: - Toolbar Buttons

extension ContentView
{
    private var editButton: some View
    {
        Button(action: { handleEdit() })
        {
            Text("Edit")
        }
        .help("Edit the selected color")
        .toolbarButtonStyle()
    }
    
    private var cameraButton: some View
    {
        Button(action: { handleCamera() })
        {
            Image(systemName: "camera")
        }
        .help("Use the system's camera to match a color")
        .toolbarButtonStyle(prominent: false)
    }
    
    private var searchButton: some View
    {
        Button(action: { handleSearch() })
        {
            Image(systemName: "magnifyingglass")
        }
        .help("Search for colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    private var filterButton: some View
    {
        Button(action: { handleFilter() })
        {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .help("Filter colors")
        .toolbarButtonStyle(prominent: false)
    }
    
    private var importButton: some View
    {
        Button(action: { handleImport() })
        {
            Image(systemName: "square.and.arrow.down")
        }
        .help("Import colors from a file")
        .toolbarButtonStyle(prominent: false)
    }
    
    private var exportButton: some View
    {
        Button(action: { handleExport() })
        {
            Image(systemName: "square.and.arrow.up")
        }
        .help("Export colors to a file")
        .toolbarButtonStyle(prominent: false)
    }
}

// MARK: - Button Actions

extension ContentView
{
    private func handleEdit()
    {
        // TODO: Implement edit functionality
    }
    
    private func handleCamera()
    {
        ShowCameraMatchView.toggle()
    }
    
    private func handleSearch()
    {
        ShowCameraMatchView.toggle()
    }
    
    private func handleFilter()
    {
        // TODO: Implement filter functionality
    }
    
    private func handleImport()
    {
        NSLog("🔵 Import button tapped")
        print("🔵 Import button tapped")
        #if os(macOS)
        print("✓ Running on macOS")
        #else
        print("⚠️ Not running on macOS - import won't work")
        #endif
        
        ColorListIO.importColorList { result in
            handleImportResult(result)
        }
    }
    
    private func handleExport()
    {
        // TODO: Implement export functionality
    }
    
    private func clearSelection()
    {
        SelectedSwatch = UUID.empty
    }
}

// MARK: - Import Handling

extension ContentView
{
    private func handleImportResult(_ result: Result<ImportedColorData, ColorListError>)
    {
        NSLog("🟢 Import callback received")
        print("🟢 Import callback received")
        
        switch result
        {
        case .success(let importedData):
            handleImportSuccess(importedData)
            
        case .failure(let error):
            handleImportFailure(error)
        }
    }
    
    private func handleImportSuccess(_ importedData: ImportedColorData)
    {
        NSLog("🟡 Import succeeded")
        print("🟡 Import succeeded, type: \(importedData.importType)")
        
        Task { @MainActor in
            print("🟠 Starting Task on MainActor")
            do
            {
                print("🔴 About to load data into ColorList")
                try ColorList.shared.loadFromImportedData(importedData)
                logImportSuccess(importedData)
            }
            catch
            {
                NSLog("❌ Failed to load: %@", error.localizedDescription)
                print("❌ Failed to load data into ColorList: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleImportFailure(_ error: ColorListError)
    {
        NSLog("❌ Import failed: %@", error.localizedDescription)
        print("❌ Import failed: \(error.localizedDescription)")
    }
    
    private func logImportSuccess(_ importedData: ImportedColorData)
    {
        let totalColors = ColorList.shared.totalColorCount()
        NSLog("✅ Successfully loaded %d colors", totalColors)
        print("✅ Successfully loaded \(totalColors) colors from \(importedData.sourceFileName ?? "unknown file")")
        
        switch importedData.importType
        {
        case .fullStructure:
            if let groups = ColorList.shared.colorGroups
            {
                print("📊 Loaded full structure with \(groups.count) top-level groups")
            }
        case .groups:
            if let groups = ColorList.shared.colorGroups
            {
                print("📊 Loaded \(groups.count) color groups")
            }
        case .records:
            print("⚠️ Warning: Individual records import attempted but rejected")
        }
    }
}

// MARK: - Color Data Extraction

extension ContentView
{
    /// Flatten all colors from ColorList into a single array
    private func getAllColors() -> [ColorRecord]
    {
        // If a group is selected, only show colors from that group
        if !selectedGroupPath.isEmpty
        {
            let colors = getColorsForSelectedPath()
            print("🎨 getAllColors() for selected path '\(selectedGroupPath.joined(separator: " > "))': \(colors.count) colors")
            return colors
        }
        
        // Otherwise show all colors
        guard let groups = colorList.colorGroups else { 
            print("🎨 getAllColors(): No color groups available")
            return [] 
        }
        
        var allColors: [ColorRecord] = []
        
        for group in groups
        {
            let groupColors = getColorsFromGroup(group)
            print("🎨 Group '\(group.Name)': extracted \(groupColors.count) colors (direct: \(group.Colors?.count ?? 0))")
            allColors.append(contentsOf: groupColors)
        }
        
        print("🎨 getAllColors() total: \(allColors.count) colors from \(groups.count) groups")
        return allColors
    }
    
    /// Get colors for the currently selected path
    private func getColorsForSelectedPath() -> [ColorRecord]
    {
        guard let groups = colorList.colorGroups else { 
            print("  ⚠️ getColorsForSelectedPath: No groups available")
            return [] 
        }
        
        print("  🔍 Searching for path: '\(selectedGroupPath.joined(separator: " > "))'")
        
        // Navigate through the path to find the selected group/collection
        var currentGroups = groups
        var targetGroup: ColorGroup?
        var targetCollection: ColorCollection?
        
        for (index, pathComponent) in selectedGroupPath.enumerated()
        {
            print("    Step \(index + 1): Looking for '\(pathComponent)' in \(currentGroups.count) groups")
            
            // Debug: Print available group names
            let groupNames = currentGroups.map { $0.Name }
            print("    Available groups: \(groupNames.joined(separator: ", "))")
            
            // Try to find in groups first
            if let group = currentGroups.first(where: { $0.Name == pathComponent })
            {
                targetGroup = group
                print("    ✓ Found group '\(pathComponent)'")
                
                // Check if this is the last component
                if index == selectedGroupPath.count - 1
                {
                    // This is the target
                    print("    ✓ This is the target group")
                    break
                }
                
                // Continue navigating - check nested groups
                if let nestedGroups = group.Groups, !nestedGroups.isEmpty
                {
                    currentGroups = nestedGroups
                    print("    → Moving to \(nestedGroups.count) nested groups")
                }
                else if let collections = group.Collections, !collections.isEmpty
                {
                    print("    → Group has \(collections.count) collections")
                    // Must be in collections then
                    if index + 1 < selectedGroupPath.count
                    {
                        let nextComponent = selectedGroupPath[index + 1]
                        print("    🔍 Searching for collection '\(nextComponent)'")
                        targetCollection = findCollectionInCollections(collections, name: nextComponent, remainingPath: Array(selectedGroupPath[(index + 2)...]))
                        break
                    }
                }
                else
                {
                    print("    ⚠️ Group has no nested groups or collections")
                    // This is a leaf group, stop here
                    break
                }
            }
            else
            {
                print("    ❌ Path component '\(pathComponent)' not found!")
                print("    UTF-8 bytes of search term: \(Array(pathComponent.utf8))")
                for groupName in groupNames
                {
                    print("    Comparing with: '\(groupName)' - UTF-8: \(Array(groupName.utf8)) - Match: \(groupName == pathComponent)")
                }
                // Path not found
                return []
            }
        }
        
        // Return colors from target
        if let collection = targetCollection
        {
            let colors = getColorsFromCollection(collection)
            print("  ✓ Extracted \(colors.count) colors from collection '\(collection.Name)'")
            return colors
        }
        else if let group = targetGroup
        {
            let colors = getColorsFromGroup(group)
            print("  ✓ Extracted \(colors.count) colors from group '\(group.Name)'")
            return colors
        }
        
        print("  ❌ No target found!")
        return []
    }
    
    /// Helper to find a collection in nested collections
    private func findCollectionInCollections(_ collections: [ColorCollection], name: String, remainingPath: [String]) -> ColorCollection?
    {
        guard let collection = collections.first(where: { $0.Name == name }) else
        {
            return nil
        }
        
        // If no more path, return this collection
        if remainingPath.isEmpty
        {
            return collection
        }
        
        // Navigate deeper
        if let nestedCollections = collection.Collections
        {
            let nextName = remainingPath[0]
            let nextRemainingPath = Array(remainingPath.dropFirst())
            return findCollectionInCollections(nestedCollections, name: nextName, remainingPath: nextRemainingPath)
        }
        
        return nil
    }
    
    /// Expand or collapse all groups
    private func expandAll()
    {
        if expandedGroups.isEmpty
        {
            // Expand all
            expandedGroups = getAllGroupPaths()
        }
        else
        {
            // Collapse all
            expandedGroups.removeAll()
        }
    }
    
    /// Get all group paths for expand/collapse all functionality
    private func getAllGroupPaths() -> Set<String>
    {
        guard let groups = colorList.colorGroups else { return [] }
        var paths = Set<String>()
        
        func collectPaths(from group: ColorGroup, parentPath: [String] = [])
        {
            let currentPath = parentPath + [group.Name]
            let pathString = currentPath.joined(separator: ".")
            paths.insert(pathString)
            
            if let nestedGroups = group.Groups
            {
                for nestedGroup in nestedGroups
                {
                    collectPaths(from: nestedGroup, parentPath: currentPath)
                }
            }
            
            if let collections = group.Collections
            {
                for collection in collections
                {
                    let collectionPath = currentPath + [collection.Name]
                    let collectionPathString = collectionPath.joined(separator: ".")
                    paths.insert(collectionPathString)
                }
            }
        }
        
        for group in groups
        {
            collectPaths(from: group)
        }
        
        return paths
    }
    
    /// Recursively extract all colors from a ColorGroup
    private func getColorsFromGroup(_ group: ColorGroup) -> [ColorRecord]
    {
        var colors: [ColorRecord] = []
        
        // Add direct colors
        if let groupColors = group.Colors
        {
            colors.append(contentsOf: groupColors)
            print("  📌 '\(group.Name)' has \(groupColors.count) direct colors")
        }
        
        // Add colors from nested groups
        if let nestedGroups = group.Groups
        {
            print("  📁 '\(group.Name)' has \(nestedGroups.count) nested groups")
            for nestedGroup in nestedGroups
            {
                let nestedColors = getColorsFromGroup(nestedGroup)
                colors.append(contentsOf: nestedColors)
            }
        }
        
        // Add colors from collections
        if let collections = group.Collections
        {
            print("  📦 '\(group.Name)' has \(collections.count) collections")
            for collection in collections
            {
                let collectionColors = getColorsFromCollection(collection)
                colors.append(contentsOf: collectionColors)
            }
        }
        
        print("  ✓ '\(group.Name)' total: \(colors.count) colors")
        return colors
    }
    
    /// Recursively extract all colors from a ColorCollection
    private func getColorsFromCollection(_ collection: ColorCollection) -> [ColorRecord]
    {
        var colors: [ColorRecord] = []
        
        // Add direct colors
        if let collectionColors = collection.Colors
        {
            colors.append(contentsOf: collectionColors)
        }
        
        // Add colors from nested collections
        if let nestedCollections = collection.Collections
        {
            for nestedCollection in nestedCollections
            {
                colors.append(contentsOf: getColorsFromCollection(nestedCollection))
            }
        }
        
        return colors
    }
}

// MARK: - Color Conversion

extension ContentView
{
    /// Convert a ColorRecord's hex value to a SwiftUI Color
    private func colorFromRecord(_ record: ColorRecord) -> Color
    {
        // Try hex first (most common in your XML)
        if let hex = record.Hex?.HexValue
        {
            return Color(hexString: hex)
        }
        
        // Fallback to RGB if available
        if let rgb = record.RGB
        {
            return Color(
                red: Double(rgb.r) / 255.0,
                green: Double(rgb.g) / 255.0,
                blue: Double(rgb.b) / 255.0
            )
        }
        
        // Fallback to gray if no color space is available
        return Color.gray
    }
    
    /// Get hex value string from ColorRecord
    private func valueFromRecord(_ record: ColorRecord) -> String
    {
        guard let hex = record.Hex?.HexValue else
        {
            return "0x??????"
        }
        if hex.starts(with: "0x")
        {
            return hex
        }
        return "0x\(hex)"
    }
}

// MARK: - Color Counting

extension ContentView
{
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
}

// MARK: - View Modifiers

extension View
{
    /// Apply toolbar button styling based on platform
    @ViewBuilder
    func toolbarButtonStyle(prominent: Bool = true) -> some View
    {
        #if os(macOS)
        self
            .buttonStyle(.bordered)
            .controlSize(.large)
        #else
        if prominent
        {
            self.buttonStyle(.borderedProminent)
        }
        else
        {
            self.buttonStyle(.bordered)
        }
        #endif
    }
}

// MARK: - Tree Node Components

/// Represents a group node in the tree structure
struct GroupTreeNode: View
{
    let group: ColorGroup
    let path: [String]
    let level: Int
    @Binding var expandedGroups: Set<String>
    @Binding var selectedGroupPath: [String]
    
    private var pathString: String
    {
        path.joined(separator: ".")
    }
    
    private var isExpanded: Bool
    {
        expandedGroups.contains(pathString)
    }
    
    private var isSelected: Bool
    {
        selectedGroupPath == path
    }
    
    private var colorCount: Int
    {
        group.Colors?.count ?? 0
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            // Group row
            HStack(spacing: 4)
            {
                // Indentation
                Color.clear
                    .frame(width: CGFloat(level * 16))
                
                // Disclosure triangle (if has children)
                if hasChildren
                {
                    Button(action: { toggleExpansion() })
                    {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                }
                else
                {
                    Color.clear
                        .frame(width: 16, height: 16)
                }
                
                // Folder icon
                Image(systemName: hasChildren ? "folder.fill" : "folder")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.system(size: 14))
                
                // Group name
                Text(group.Name)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .primary : .primary)
                
                Spacer()
                
                // Color count badge
                if colorCount > 0
                {
                    Text("\(colorCount)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 4)
            .padding(.trailing, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture
            {
                selectedGroupPath = path
            }
            
            // Nested groups (if expanded)
            if isExpanded
            {
                if let nestedGroups = group.Groups
                {
                    ForEach(nestedGroups, id: \.Name) { nestedGroup in
                        GroupTreeNode(
                            group: nestedGroup,
                            path: path + [nestedGroup.Name],
                            level: level + 1,
                            expandedGroups: $expandedGroups,
                            selectedGroupPath: $selectedGroupPath
                        )
                    }
                }
                
                // Collections
                if let collections = group.Collections
                {
                    ForEach(collections, id: \.Name) { collection in
                        CollectionTreeNode(
                            collection: collection,
                            path: path + [collection.Name],
                            level: level + 1,
                            expandedGroups: $expandedGroups,
                            selectedGroupPath: $selectedGroupPath
                        )
                    }
                }
            }
        }
    }
    
    private var hasChildren: Bool
    {
        (group.Groups?.isEmpty == false) || (group.Collections?.isEmpty == false)
    }
    
    private func toggleExpansion()
    {
        if isExpanded
        {
            expandedGroups.remove(pathString)
        }
        else
        {
            expandedGroups.insert(pathString)
        }
    }
}

/// Represents a collection node in the tree structure
struct CollectionTreeNode: View
{
    let collection: ColorCollection
    let path: [String]
    let level: Int
    @Binding var expandedGroups: Set<String>
    @Binding var selectedGroupPath: [String]
    
    private var pathString: String
    {
        path.joined(separator: ".")
    }
    
    private var isExpanded: Bool
    {
        expandedGroups.contains(pathString)
    }
    
    private var isSelected: Bool
    {
        selectedGroupPath == path
    }
    
    private var colorCount: Int
    {
        collection.Colors?.count ?? 0
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            // Collection row
            HStack(spacing: 4)
            {
                // Indentation
                Color.clear
                    .frame(width: CGFloat(level * 16))
                
                // Disclosure triangle (if has nested collections)
                if hasNestedCollections
                {
                    Button(action: { toggleExpansion() })
                    {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                }
                else
                {
                    Color.clear
                        .frame(width: 16, height: 16)
                }
                
                // Collection icon
                Image(systemName: "tray.fill")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.system(size: 12))
                
                // Collection name
                Text(collection.Name)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .primary : .primary)
                
                Spacer()
                
                // Color count badge
                if colorCount > 0
                {
                    Text("\(colorCount)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 4)
            .padding(.trailing, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture
            {
                selectedGroupPath = path
            }
            
            // Nested collections (if expanded)
            if isExpanded, let nestedCollections = collection.Collections
            {
                ForEach(nestedCollections, id: \.Name) { nestedCollection in
                    CollectionTreeNode(
                        collection: nestedCollection,
                        path: path + [nestedCollection.Name],
                        level: level + 1,
                        expandedGroups: $expandedGroups,
                        selectedGroupPath: $selectedGroupPath
                    )
                }
            }
        }
    }
    
    private var hasNestedCollections: Bool
    {
        collection.Collections?.isEmpty == false
    }
    
    private func toggleExpansion()
    {
        if isExpanded
        {
            expandedGroups.remove(pathString)
        }
        else
        {
            expandedGroups.insert(pathString)
        }
    }
}

#Preview
{
    ContentView()
        .environmentObject(ColorList.shared)
}

extension UUID
{
    static var empty: UUID
    {
        return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}

// MARK: - Color Extension for Hex Conversion

extension Color
{
    /// Initialize a Color from a hex string (e.g., "FF0000" or "#FF0000")
    init(hexString: String)
    {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove # prefix if present
        if hex.hasPrefix("#")
        {
            hex.remove(at: hex.startIndex)
        }
        
        // Ensure it's 6 or 8 characters
        guard hex.count == 6 || hex.count == 8 else
        {
            self = Color.gray
            return
        }
        
        // Parse hex value
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let r: Double
        let g: Double
        let b: Double
        let a: Double
        
        if hex.count == 8
        {
            // RGBA
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        }
        else
        {
            // RGB
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        }
        
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
}
