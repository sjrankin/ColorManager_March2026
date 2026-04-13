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
