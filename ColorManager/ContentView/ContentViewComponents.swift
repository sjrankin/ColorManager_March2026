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

            // Center - Color grid
            colorDisplayArea
                .frame(minWidth: 400)

            // Right side - Color info panel (visible when toggled)
            if ShowColorInfoPanel
            {
                colorInfoPanel
                    .frame(minWidth: 200, idealWidth: 280, maxWidth: 500)
            }
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
                               SwatchWidth: SwatchSize,
                               onTap: { SelectedColorRecord = colorRecord })
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

    /// Right-side color info panel
    var colorInfoPanel: some View
    {
        VStack(spacing: 0)
        {
            // Header
            HStack
            {
                Text("Color Info")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Spacer()
            }
#if os(macOS)
            .background(Color(nsColor: .controlBackgroundColor))
#else
            .background(Color(uiColor: .systemBackground))
#endif

            Divider()

            if let record = SelectedColorRecord
            {
                ScrollView
                {
                    VStack(alignment: .leading, spacing: 12)
                    {
                        // Container path (parent: closest)
                        let path = pathForColor(record)
                        if path.count >= 2
                        {
                            Text("\(path[path.count - 2]): \(path[path.count - 1])")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                        }
                        else if path.count == 1
                        {
                            Text(path[0])
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                        }

                        // Color swatch preview
                        colorFromRecord(record)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .cornerRadius(6)
                            .padding(.horizontal, 12)
                            .padding(.top, path.count >= 1 ? 4 : 12)

                        // Name
                        VStack(alignment: .leading, spacing: 4)
                        {
                            Text("Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(record.Name)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 12)

                        // Alternative names
                        if let altNames = record.AlternativeNames, !altNames.isEmpty
                        {
                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text("Also Known As")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(altNames, id: \.self)
                                { name in
                                    Text(name)
                                        .font(.body)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        else if let altName = record.AlternativeName
                        {
                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text("Also Known As")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(altName)
                                    .font(.body)
                            }
                            .padding(.horizontal, 12)
                        }

                        Divider()
                            .padding(.horizontal, 12)

                        // Color space values
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Color Values")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let hex = record.Hex
                            {
                                colorInfoRow(label: "Hex", value: hex.AsString())
                            }
                            if let rgb = record.RGB
                            {
                                colorInfoRow(label: "RGB", value: rgb.AsString())
                            }
                            if let hsl = record.HSL
                            {
                                colorInfoRow(label: "HSL", value: hsl.AsString())
                            }
                            if let hsb = record.HSB
                            {
                                colorInfoRow(label: "HSB", value: hsb.AsString())
                            }
                            if let cmyk = record.CMYK
                            {
                                colorInfoRow(label: "CMYK", value: cmyk.AsString())
                            }
                            if let lab = record.LAB
                            {
                                colorInfoRow(label: "LAB", value: lab.AsString())
                            }
                        }
                        .padding(.horizontal, 12)

                        // Tags
                        if let tags = record.Tags, !tags.isEmpty
                        {
                            Divider()
                                .padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text("Tags")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                FlowLayout(tags)
                            }
                            .padding(.horizontal, 12)
                        }

                        Spacer(minLength: 12)
                    }
                }
            }
            else
            {
                Spacer()
                Text("Tap a color to see its info")
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        }
#if os(macOS)
        .background(Color(nsColor: .textBackgroundColor))
#else
        .background(Color(uiColor: .systemBackground))
#endif
    }

    /// A single label/value row for color space info
    @ViewBuilder
    func colorInfoRow(label: String, value: String) -> some View
    {
        HStack(alignment: .top)
        {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)
            Spacer()
        }
    }

    /// Simple wrapping tag layout
    struct FlowLayout: View
    {
        let tags: [String]

        init(_ tags: [String])
        {
            self.tags = tags
        }

        var body: some View
        {
            // Use a simple vertical list for tags since flow layout needs iOS 16+
            VStack(alignment: .leading, spacing: 4)
            {
                ForEach(tags, id: \.self)
                { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(10)
                }
            }
        }
    }
}

