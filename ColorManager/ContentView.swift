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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 96)), count: 3))
                {
                    SwatchView(SwatchColor: Color.orange,
                               SwatchColorName: "Dark Orange")
                    .padding(4)
                    SwatchView(SwatchColor: Color.red,
                               SwatchColorName: "Ugly Red")
                    .padding(4)
                    SwatchView(SwatchColor: Color.accentColor,
                               SwatchColorName: "Accent")
                    .padding(4)
                    SwatchView(SwatchColor: Color.pink,
                               SwatchColorName: "Really Dark Pink")
                    .padding(4)
                }
            }
            .background(Color(UIColor.systemGray4))
        }
}

#Preview
{
    ContentView()
}
