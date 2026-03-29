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
    #if os(macOS)
    @State var PaletteBackground: Color = Color(nsColor: NSColor.controlBackgroundColor)
    #else
    @State var PaletteBackground: Color = Color(UIColor.systemGray5)
    #endif
    
    let PaletteColumns = [GridItem(.adaptive(minimum: 90))]
    
    var SwatchSize: CGFloat = 90
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Button("Edit")
                {
                    ShowEditor.toggle()
                }
                .buttonStyle(.glassProminent)
                
                Button(action:
                        {
                    ShowCameraMatchView.toggle()
                })
                {
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                
                Button(action:
                        {
                    ShowCameraMatchView.toggle()
                })
                {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                
                Button(action:
                        {
                    
                })
                {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                .padding(.trailing, 10)
                
                Button(action:
                        {
                    
                })
                {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                
                Button(action:
                        {
                    
                })
                {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
                .buttonStyle(.glassProminent)
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.top, 2)
        }
        ScrollView
        {
            LazyVGrid(columns: PaletteColumns, spacing: 1.0)
            {
                SwatchView(SwatchColor: Color.orange,
                           SwatchColorName: "Dark Orange",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: Color.red,
                           SwatchColorName: "Ugly Red",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: Color.accentColor,
                           SwatchColorName: "Accent",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: Color.pink,
                           SwatchColorName: "Really Dark Pink",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: TestColor.GetColor(.SystemYellow),
                           SwatchColorName: TestColor.GetColorName(.SystemYellow),
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: TestColor.GetColor(.JapaneseFlagRed),
                           SwatchColorName: TestColor.GetColorName(.JapaneseFlagRed),
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: TestColor.GetColor(.ReallyLongColorName),
                           SwatchColorName: TestColor.GetColorName(.ReallyLongColorName),
                           SwatchWidth: SwatchSize)
                .padding(4)
            }
            .padding(.horizontal, 8)
        }
        .background(PaletteBackground)
    }
}

#Preview
{
    ContentView()
}
