//
//  ColorValueSearchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/17/26.
//

import SwiftUI

struct ColorValueSearchView: View
{
    @Binding var Searcher: SearchRecord?
    
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                Text("Color Value Search")
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview
{
    @Previewable @State var SearchHow: SearchRecord? = nil
    
    ColorValueSearchView(Searcher: $SearchHow)
}
