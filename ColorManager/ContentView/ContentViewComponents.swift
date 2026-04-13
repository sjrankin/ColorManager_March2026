//
//  ContentViewComponents.swift
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

// MARK: - View Components

extension ContentView
{
    /// Toolbar with action buttons
     var toolbarView: some View
    {
        HStack(spacing: 8)
        {
            editButton
            cameraButton
            searchButton
            filterButton
                .padding(.trailing, 16)
            importButton
            exportButton
                .padding(.trailing, 16)
            paletteButton
            createColorButton
            infoButton
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
     var colorGridView: some View
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
     var structureNavigator: some View
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
                        ForEach(Array(groups.enumerated()), id: \.element.Name)
                        {
                            index, group in
                            GroupTreeNode(group: group,
                                          path: [group.Name],
                                          level: 0,
                                          expandedGroups: $expandedGroups,
                                          selectedGroupPath: $selectedGroupPath)
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
     var colorDisplayArea: some View
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
     var colorGrid: some View
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
                ForEach(allColors, id: \.id)
                {
                    colorRecord in
                    SwatchView(SelectedID: $SelectedSwatch,
                               SwatchColor: colorFromRecord(colorRecord),
                               SwatchColorName: colorRecord.Name,
                               SwatchColorValue: valueFromRecord(colorRecord),
                               SwatchWidth: SwatchSize)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }
    
    /// Empty state when no colors are loaded
     var emptyStateView: some View
    {
        Text("No colors loaded")
            .foregroundColor(.secondary)
            .padding()
    }
    
    /// Spacer that clears selection when tapped
     var clearSelectionSpacer: some View
    {
        Color.clear
            .frame(minHeight: 100)
            .contentShape(Rectangle())
            .onTapGesture { clearSelection() }
    }
}

