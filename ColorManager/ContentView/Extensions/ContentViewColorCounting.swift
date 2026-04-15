//
//  ContentViewColorCounting.swift
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

// MARK: - Color Counting

extension ContentView
{
    /// Recursively count all colors in a ColorGroup, including nested groups and collections
    func countColorsInGroup(_ group: ColorGroup) -> Int
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
    func countColorsInCollection(_ collection: ColorCollection) -> Int
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
    func countAllColors(_ colors: Colors) -> Int
    {
        guard let groups = colors.ColorGroups else { return 0 }
        return groups.reduce(0) { $0 + countColorsInGroup($1) }
    }
}

