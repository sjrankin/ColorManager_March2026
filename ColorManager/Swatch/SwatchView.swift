//
//  SwatchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import SwiftUI

struct SwatchView: View
{
    @State var ColorID: UUID? = nil
    @State var SwatchColor: Color = .red
    @State var SwatchColorName: String = "Test Name That Is Too Long"
    @State var SwatchWidth: CGFloat = 96
    @State var SwatchHeaderHeight: CGFloat = 48
    @State var ShowShadow: Bool = true
    @State var CanTap: Bool = true
    let CornerRadius: CGFloat = 2.0
    
    var body: some View
    {
        VStack
        {
            if let ColorID = ColorID
            {
                // Get the color from the color manager and use that data here
            }
            else
            {
                SwatchHeader(ColorName: SwatchColorName,
                             SwatchWidth: SwatchWidth,
                             HeaderHeight: SwatchHeaderHeight)
                .padding(.bottom, -8)
                SwatchColorView(TheColor: SwatchColor,
                                SideLength: SwatchWidth)
            }
        }
        .frame(width: SwatchWidth)
        .background(.white)
        .border(Color(.black))
        .cornerRadius(CornerRadius)
        .overlay(RoundedRectangle(cornerRadius: CornerRadius)
            .stroke(.black, lineWidth: 1.0))
        .compositingGroup()
        .shadow(color: Color.black.opacity(ShowShadow ? 0.4 : 0.0),
                radius: 2,
                x: 2, y: 2)
        .onTapGesture
        {
            print("\(SwatchColorName) tapped")
        }
    }
}

#Preview {
    SwatchView(SwatchColor: .indigo,
               SwatchWidth: 86)
}
