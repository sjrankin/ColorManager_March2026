//
//  ColorCameraSearchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/17/26.
//

import SwiftUI

struct ColorCameraSearchView: View
{
    @Binding var Searcher: SearchRecord?

    var body: some View
    {
        CameraView()
    }
}

#Preview
{
    @Previewable @State var SearchHow: SearchRecord? = nil
    
    ColorCameraSearchView(Searcher: $SearchHow)
}
