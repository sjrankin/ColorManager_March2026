//
//  ContentViewColorConversion.swift
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

// MARK: - Color Conversion

extension ContentView
{
    /// Convert a ColorRecord's hex value to a SwiftUI Color
    func colorFromRecord(_ record: ColorRecord) -> Color
    {
        // Try hex first (most common in your XML)
        if let hex = record.Hex?.HexValue
        {
            return Color(hexString: hex)
        }
        
        // Fallback to RGB if available
        if let rgb = record.RGB
        {
            return Color(
                red: Double(rgb.r) / 255.0,
                green: Double(rgb.g) / 255.0,
                blue: Double(rgb.b) / 255.0
            )
        }
        
        // Fallback to gray if no color space is available
        return Color.gray
    }
    
    /// Get hex value string from ColorRecord
    func valueFromRecord(_ record: ColorRecord) -> String
    {
        guard let hex = record.Hex?.HexValue else
        {
            return "0x??????"
        }
        if hex.starts(with: "0x")
        {
            return hex
        }
        return "0x\(hex)"
    }
}

