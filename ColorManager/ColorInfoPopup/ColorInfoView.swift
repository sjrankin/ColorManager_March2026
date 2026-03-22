//
//  ColorInfoView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import SwiftUI

struct ColorInfoView: View
{
    @State var TheColorID: UUID? = nil
    @Environment(\.dismiss) var Dismiss
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Text("Color Information")
                    .font(.headline)
                Spacer()
            }
            Divider()
            if let ColorID = TheColorID
            {
                ScrollView
                {
                    //color swatch
                    //numeric values
                    //names
                }
            }
            else
            {
                Text("No color ID provided.")
            }
            Spacer()
            Divider()
            HStack
            {
                Spacer()
                Button("Close")
                {
                    Dismiss()
                }
                .buttonStyle(.glassProminent)
                Spacer()
            }
        }
        .frame(height: 400)
    }
}

#Preview
{
    ColorInfoView()
}
