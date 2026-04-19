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
    @State var selectedGroupPath: [String] = [] // Track selected group hierarchy
    @State var expandedGroups: Set<String> = [] // Track expanded groups
    @State var ShowColorInfoPanel: Bool = false
    @State var ShowColorSearchView: Bool = false
#if !os(macOS)
    @State var ShowStructureNavigator: Bool = false
#endif
    @AppStorage("ViewStyle") var ViewStyle: Int = 0
    @State var SelectedColorRecord: ColorRecord? = nil
    
#if os(macOS)
    let GroupSpacer: Double = 16
#else
    let GroupSpacer: Double = 0.0
#endif
    
    #if os(macOS)
    @State var PaletteBackground: Color = Color(nsColor: NSColor.controlBackgroundColor)
    #else
    @State var PaletteBackground: Color = Color(UIColor.systemGray5)
    #endif
    
    // Use flexible columns that maintain consistent spacing
    let PaletteColumns =
    [
        GridItem(.adaptive(minimum: 90, maximum: 120), spacing: 8)
    ]
    
    var SwatchSize: CGFloat = 90

#if os(macOS)
    @Environment(\.openWindow) var openWindow
#endif

    var body: some View
    {
        VStack(spacing: 0)
        {
            toolbarView
            Divider()
            colorGridView
        }
#if os(macOS)
        .onChange(of: ShowColorSearchView)
        { _, newValue in
            if newValue
            {
                openWindow(id: "color-searcher")
                ShowColorSearchView = false
            }
        }
#else
        .sheet(isPresented: $ShowColorSearchView)
        {
            ColorSearchView()
        }
#endif
        .sheet(isPresented: $ShowCameraMatchView)
        {
            ColorCameraSearchView(Searcher: .constant(nil))
        }
    }
}

enum ViewStyles: Int
{
    case Swatches = 0
    case List = 1
    
    static func Is(_ Raw: Int) -> ViewStyles
    {
        guard let Converted = ViewStyles(rawValue: Raw) else { return .Swatches }
        return Converted
    }
}
