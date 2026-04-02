//
//  SwatchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import SwiftUI

struct SwatchView: View
{
    @State var ColorID: UUID?
    @Binding var SelectedID: UUID
    var InstanceID = UUID()
    @State var SwatchColor: Color = .red
    @State var SwatchColorName: String = "Test Name That Is Too Long"
    @State var SwatchColorValue: String = "0x000000"
    @State var SwatchWidth: CGFloat = 96
    @State var SwatchHeaderHeight: CGFloat = 48
    @State var ShowShadow: Bool = true
    @State var CanTap: Bool = true
    let CornerRadius: CGFloat = 2.0
    @State var ShadowColor: Color = .black.opacity(0.4)
    @State var BorderColor: Color = .black
    @State var BorderThickness: CGFloat = 1.0
    @State var SwatchHeaderBackground: Color = .gray.opacity(0.15)
    @State var ShadowRadius: CGFloat = 2.0
    @State var ShadowXOffset: CGFloat = 2.0
    @State var ShadowYOffset: CGFloat = 2.0
    
    var body: some View
    {
        VStack
        {
            SwatchHeader(ColorName: SwatchColorName,
                         ColorValue: SwatchColorValue,
                         SwatchWidth: SwatchWidth,
                         HeaderHeight: SwatchHeaderHeight,
                         BackgroundColor: $SwatchHeaderBackground)
            .padding(.bottom, -8)
            SwatchColorView(TheColor: SwatchColor,
                            SideLength: SwatchWidth)
        }
        .frame(width: SwatchWidth)
        .background(.white)
        .border(BorderColor)
        .cornerRadius(CornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CornerRadius)
            .stroke(BorderColor, lineWidth: BorderThickness))
        .compositingGroup()
        .shadow(color: ShadowColor,
                radius: ShadowRadius,
                x: ShadowXOffset,
                y: ShadowYOffset)
        .onTapGesture
        {
            SelectedID = InstanceID
        }
        .onChange(of: SelectedID)
        {
            old, new in
            if new == InstanceID
            {
                SwatchHeaderBackground = .white
                BorderThickness = 2.0
                #if os(macOS)
                BorderColor = Color(nsColor: NSColor.controlAccentColor)
                ShadowColor = SwatchColor
                #else
                BorderColor = Color(UIColor.tintColor)
                ShadowColor = SwatchColor
                #endif
                ShadowRadius = 4.0
                ShadowXOffset = 0.0
                ShadowYOffset = 0.0
            }
            else
            {
                SwatchHeaderBackground = .gray.opacity(0.15)
                BorderThickness = 1.0
                BorderColor = .black
                ShadowColor = .black.opacity(0.4)
                ShadowRadius = 2.0
                ShadowXOffset = 2.0
                ShadowYOffset = 2.0
            }
        }
    }
}

#Preview
{
    @Previewable @State var SwatchID: UUID = UUID()
    SwatchView(SelectedID: $SwatchID,
               SwatchColor: .indigo,
               SwatchWidth: 86)
}
