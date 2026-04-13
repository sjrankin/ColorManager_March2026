//
//  ColorGeneratorView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import SwiftUI

struct ColorGeneratorView: View
{
    @Environment(\.dismiss) var Dismiss
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("Color Generator")
            }
            Divider()
            VStack
            {
                HStack
                {
                    Text("Enter the description of the color.")
                    Spacer()
                }
                HStack
                {
                    TextField("", text: .constant(""))
                    Spacer()
                }
            }
            Divider()
            HStack
            {
                Button("Done")
                {
                    self.Dismiss()
                }
            }
        }
    }
}

#Preview
{
    ColorGeneratorView()
}
