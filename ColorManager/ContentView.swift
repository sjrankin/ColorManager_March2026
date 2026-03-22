//
//  ContentView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/20/26.
//

import SwiftUI

struct ContentView: View
{
    @State var ShowEditor: Bool = false
    @State var SearchColor: Bool = false
    @State var ShowCameraMatchView: Bool = false
    @State var PaletteBackground: Color = Color(UIColor.systemGray5)
    
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
                SwatchView(SwatchColor: Color(UIColor.systemYellow),
                           SwatchColorName: "SystemYellow",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: Color(UIColor(red: 188.0 / 255.0, green: 0, blue: 45.0 / 255.0, alpha: 1.0)),
                           SwatchColorName: "Japanese Flag Red",
                           SwatchWidth: SwatchSize)
                .padding(4)
                SwatchView(SwatchColor: Color(UIColor(red: 198.0 / 255.0, green: 50.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)),
                           SwatchColorName: "Really really long color name here",
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
