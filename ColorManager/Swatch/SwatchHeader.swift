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
    @State var SwatchWidth: CGFloat = 96
    @State var HeaderHeight: CGFloat = 32
    
    var body: some View
    {
        ZStack
        {
            HStack
            {
                Text(ColorName)
                    .font(.caption)
                Spacer()
            }
            .frame(width: SwatchWidth - 16)
            VStack
            {
                HStack
                {
                    Spacer()
                    Button(action:
                            {
                        
                    })
                    {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
        }
        .background(Color.white)
        .frame(height: HeaderHeight)
    }
}

#Preview
{
    SwatchHeader(ColorName: "Long color name here")
}
