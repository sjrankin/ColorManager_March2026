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
    
    /// Get colors for the currently selected path.
    /// Navigates the group/collection hierarchy using the path components, handling
    /// group→group, group→collection, collection→group, and collection→collection transitions.
    func getColorsForSelectedPath() -> [ColorRecord]
    {
        guard let groups = colorList.colorGroups, !selectedGroupPath.isEmpty else { return [] }

        guard let rootGroup = groups.first(where: { $0.Name == selectedGroupPath[0] }) else { return [] }

        return navigateGroup(rootGroup, remainingPath: Array(selectedGroupPath.dropFirst()))
    }

    private func navigateGroup(_ group: ColorGroup, remainingPath: [String]) -> [ColorRecord]
    {
        if remainingPath.isEmpty { return getColorsFromGroup(group) }

        let next = remainingPath[0]
        let rest = Array(remainingPath.dropFirst())

        if let nestedGroup = group.Groups?.first(where: { $0.Name == next })
        {
            return navigateGroup(nestedGroup, remainingPath: rest)
        }
        if let collection = group.Collections?.first(where: { $0.Name == next })
        {
            return navigateCollection(collection, remainingPath: rest)
        }
        return []
    }

    private func navigateCollection(_ collection: ColorCollection, remainingPath: [String]) -> [ColorRecord]
    {
        if remainingPath.isEmpty { return getColorsFromCollection(collection) }

        let next = remainingPath[0]
        let rest = Array(remainingPath.dropFirst())

        if let nestedGroup = collection.Groups?.first(where: { $0.Name == next })
        {
            return navigateGroup(nestedGroup, remainingPath: rest)
        }
        if let nestedCollection = collection.Collections?.first(where: { $0.Name == next })
        {
            return navigateCollection(nestedCollection, remainingPath: rest)
        }
        return []
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

        if let collectionColors = collection.Colors
        {
            colors.append(contentsOf: collectionColors)
        }

        if let groups = collection.Groups
        {
            for group in groups
            {
                colors.append(contentsOf: getColorsFromGroup(group))
            }
        }

        if let nestedCollections = collection.Collections
        {
            for nestedCollection in nestedCollections
            {
                colors.append(contentsOf: getColorsFromCollection(nestedCollection))
            }
        }

        return colors
    }

    /// Returns the path (group/collection names) to the container that holds the given color.
    /// The last element is the immediate container; the one before it is its parent.
    func pathForColor(_ record: ColorRecord) -> [String]
    {
        guard let groups = colorList.colorGroups else { return [] }
        for group in groups
        {
            if let path = searchGroup(group, target: record.id, currentPath: [group.Name])
            {
                return path
            }
        }
        return []
    }

    private func searchGroup(_ group: ColorGroup, target: UUID, currentPath: [String]) -> [String]?
    {
        if group.Colors?.contains(where: { $0.id == target }) == true
        {
            return currentPath
        }
        if let nestedGroups = group.Groups
        {
            for nested in nestedGroups
            {
                if let found = searchGroup(nested, target: target, currentPath: currentPath + [nested.Name])
                {
                    return found
                }
            }
        }
        if let collections = group.Collections
        {
            for collection in collections
            {
                if let found = searchCollection(collection, target: target, currentPath: currentPath + [collection.Name])
                {
                    return found
                }
            }
        }
        return nil
    }

    private func searchCollection(_ collection: ColorCollection, target: UUID, currentPath: [String]) -> [String]?
    {
        if collection.Colors?.contains(where: { $0.id == target }) == true
        {
            return currentPath
        }
        if let groups = collection.Groups
        {
            for group in groups
            {
                if let found = searchGroup(group, target: target, currentPath: currentPath + [group.Name])
                {
                    return found
                }
            }
        }
        if let nested = collection.Collections
        {
            for sub in nested
            {
                if let found = searchCollection(sub, target: target, currentPath: currentPath + [sub.Name])
                {
                    return found
                }
            }
        }
        return nil
    }

}
