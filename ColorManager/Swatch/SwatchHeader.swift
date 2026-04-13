//
//  SwatchHeader.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import SwiftUI

struct SwatchHeader: View
{
    var ColorName: String = "Name of Color"
    var ColorValue: String = "0x000000"
    var ShowColorValue: Bool = true
    var SwatchWidth: CGFloat = 96
    var HeaderHeight: CGFloat = 38
    @Binding var BackgroundColor: Color
    
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
    @Previewable @State var BGColor = Color.white
    SwatchHeader(ColorName: "fred", BackgroundColor: $BGColor)
}
