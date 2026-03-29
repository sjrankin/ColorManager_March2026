//
//  TestColors.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/29/26.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Test colors intended only for UI testing.
class TestColor
{
    /// Get a test color.
    /// - Parameter color: The color to return.
    /// - Returns: SwiftUI color defined by `color`.
    static func GetColor(_ color: TestColors) -> Color
    {
        switch color
        {
            case .SystemYellow:
#if os(macOS)
                return .yellow
#else
                return Color(UIColor.systemYellow)
#endif
            case .JapaneseFlagRed:
#if os(macOS)
                return Color(nsColor: NSColor(red: 188.0 / 255.0, green: 0, blue: 45.0 / 255.0, alpha: 1.0))
#else
                return Color(UIColor(red: 188.0 / 255.0, green: 0, blue: 45.0 / 255.0, alpha: 1.0))
#endif
            case .ReallyLongColorName:
#if os(macOS)
                return Color(nsColor: NSColor(red: 198.0 / 255.0, green: 50.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0))
#else
                return Color(UIColor(red: 198.0 / 255.0, green: 50.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0))
#endif
        }
    }
    
    /// Return the name of the specified test color.
    /// - Parameter color: Determines which color name is returned.
    /// - Returns: The color name.
    static func GetColorName(_ color: TestColors) -> String
    {
        switch color
        {
            case .SystemYellow:
#if os(macOS)
                return "Yellow"
#else
                return "SystemYellow"
#endif
                
            case .JapaneseFlagRed:
                return "Japanese Flag Red"
                
            case .ReallyLongColorName:
                return "Really really long color name here"
        }
    }
}

/// Defines test colors. Not all colors are valid on all UI types.
enum TestColors
{
    case SystemYellow
    case JapaneseFlagRed
    case ReallyLongColorName
}
