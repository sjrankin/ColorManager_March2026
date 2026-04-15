//
//  ColorSearchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/15/26.
//

import Foundation

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ColorSearchView: View
{
    @Environment(\.dismiss) var Dismiss
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                Spacer()
                Text("Color Searcher")
                    .font(.title)
                Spacer()
            }
            Divider()
            Spacer()
            Divider()
            HStack
            {
                Spacer()
                Button("Search")
                {
                    
                }
                Spacer()
                Button("Cancel")
                {
                    self.Dismiss()
                }
                Spacer()
            }
        }
    }
}
