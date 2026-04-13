//
//  ContentViewColorDataExtraction.swift
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

// MARK: - Color Data Extraction

extension ContentView
{
    /// Flatten all colors from ColorList into a single array
    func getAllColors() -> [ColorRecord]
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
    func getColorsForSelectedPath() -> [ColorRecord]
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
    func findCollectionInCollections(_ collections: [ColorCollection], name: String, remainingPath: [String]) -> ColorCollection?
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
    func expandAll()
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
    func getAllGroupPaths() -> Set<String>
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
    func getColorsFromGroup(_ group: ColorGroup) -> [ColorRecord]
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
    func getColorsFromCollection(_ collection: ColorCollection) -> [ColorRecord]
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
