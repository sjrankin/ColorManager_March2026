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
    @State var SwatchColorName: String = "Test Name"
    @State var SwatchWidth: CGFloat = 96
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
                SwatchHeader(ColorName: SwatchColorName)
                    .padding(2)
                SwatchColorView(TheColor: SwatchColor,
                                SideLength: SwatchWidth)
            }
        }
        .frame(width: SwatchWidth)
        .border(Color(.black))
    }
}

#Preview {
    SwatchView(SwatchColor: .indigo,
               SwatchWidth: 86)
}
