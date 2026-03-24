//
//  SwatchHeader.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import SwiftUI

struct SwatchHeader: View
{
    @State var ColorName: String = "Name of Color"
    @State var ColorValue: String = "0x000000"
    @State var ShowColorValue: Bool = true
    @State var SwatchWidth: CGFloat = 96
    @State var HeaderHeight: CGFloat = 38
    @State var BackgroundColor: Color = .white
    
    var body: some View
    {
        VStack
        {
            HStack(alignment: .top)
            {
                Text(ColorName)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .padding(.leading, 2)
                Spacer()
            }
            Spacer()
            if ShowColorValue
            {
                HStack(alignment: .bottom)
                {
                    Text(ColorValue)
                        .font(.system(size: 11))
                        .monospaced()
                        .padding(.leading, 2)
                    Spacer()
                }
            }
        }
        .frame(width: SwatchWidth, height: HeaderHeight + 4)
        .background(BackgroundColor)
    }
}

#Preview
{
    SwatchHeader(ColorName: "fred")//"Long color name here")
}
