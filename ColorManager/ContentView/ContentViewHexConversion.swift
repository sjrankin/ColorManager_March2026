//
//  ContentViewHexConversion.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Color Extension for Hex Conversion

extension Color
{
    /// Initialize a Color from a hex string (e.g., "FF0000" or "#FF0000")
    init(hexString: String)
    {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove # prefix if present
        if hex.hasPrefix("#")
        {
            hex.remove(at: hex.startIndex)
        }
        
        // Ensure it's 6 or 8 characters
        guard hex.count == 6 || hex.count == 8 else
        {
            self = Color.gray
            return
        }
        
        // Parse hex value
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let r: Double
        let g: Double
        let b: Double
        let a: Double
        
        if hex.count == 8
        {
            // RGBA
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        }
        else
        {
            // RGB
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        }
        
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
}

