//
//  Convert.swift
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

class Convert
{
    // MARK: - Data to PlatformColor
    
    /// Convert passed color channel values to a `PlatformColor`.
    /// - Parameter R: The red channel in integer form. Valid range is `0` - `255`.
    /// - Parameter G: The green channel in integer form. Valid range is `0` - `255`.
    /// - Parameter G: The blue channel in integer form. Valid range is `0` - `255`.
    /// - Returns: Platform color based on the passed values.
    static func FromRGB(_ R: Int, _ G: Int, _ B: Int) -> PlatformColor
    {
        return FromRGB(R: Double(R) / 255.0, G: Double(G) / 255.0, B: Double(B) / 255.0)
    }
    
    static func FromRGB(R: Double, G: Double, B: Double) -> PlatformColor
    {
        #if os(macOS)
        return NSColor(red: R.ChannelClamped(),
                       green: G.ChannelClamped(),
                       blue: B.ChannelClamped(),
                       alpha: 1.0)
        #else
        return UIColor(red: R.ChannelClamped(),
                       green: G.ChannelClamped(),
                       blue: B.ChannelClamped(),
                       alpha: 1.0)
        #endif
    }
    
    static func FromHex(_ Hex: String) -> PlatformColor
    {
        if Hex.isEmpty
        {
            return PlatformColor.black
        }
        if Hex.count != 8
        {
            return PlatformColor.black
        }
        let HexNoPrefix = String(Hex.dropFirst(2))
        guard let R = Int(HexNoPrefix.prefix(2), radix: 16),
              let G = Int(HexNoPrefix.dropFirst(2).prefix(2), radix: 16),
              let B = Int(HexNoPrefix.dropFirst(4).prefix(2), radix: 16) else
        {
            return PlatformColor.black
        }
        return FromRGB(R, G, B)
    }
    
    static func FromHexToChannels(_ Hex: String) -> (red: Int, green: Int, blue: Int)
    {
        if Hex.isEmpty
        {
            return (0, 0, 0)
        }
        if Hex.count != 8
        {
            return (0, 0, 0)
        }
        let HexNoPrefix = String(Hex.dropFirst(2))
        guard let R = Int(HexNoPrefix.prefix(2), radix: 16),
              let G = Int(HexNoPrefix.dropFirst(2).prefix(2), radix: 16),
              let B = Int(HexNoPrefix.dropFirst(4).prefix(2), radix: 16) else
        {
            return (0, 0, 0)
        }
        return (R, G, B)
    }
    
    // MARK: - PlatformColor to Channels
    
    static func IntChannels(From color: PlatformColor) -> (red: Int, green: Int, blue: Int)
    {
        #if os(macOS)
        guard let cscolor = color.usingColorSpace(.sRGB) else
        {
            print("\(#function): Error convering NSColor to RGB.")
            return (red: 0, green: 0, blue: 0)
        }
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        cscolor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: Int(red * 255), green: Int(green * 255), blue: Int(blue * 255))
        #else
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return  (red: Int(red * 255), green: Int(green * 255), blue: Int(blue * 255))
        }
        print("\(#function): Error converting UIColor to RGB.")
        return (red: 0, green: 0, blue: 0)
        #endif
    }
    
    static func DoubleChannels(From color: PlatformColor) -> (red: Double, green: Double, blue: Double)
    {
#if os(macOS)
        guard let cscolor = color.usingColorSpace(.sRGB) else
        {
            print("\(#function): Error convering NSColor to RGB.")
            return (red: 0, green: 0, blue: 0)
        }
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        cscolor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue)
#else
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return  (red: red, green: green, blue: blue)
        }
        print("\(#function): Error converting UIColor to RGB.")
        return (red: 0.0, green: 0.0, blue: 0.0)
#endif
    }
    
    /// Given the passed `PlatformColor` return it's hex value as a string.
    /// - Parameter From: The `PlatformColor` whose hex value will be returned.
    /// - Parameter AddPrefix: If `true`, "`0x`" will prefix the string. If `false`, there will be no added prefix.
    /// - Returns: The hex values of the channels of the passed `PlatformColor`.
    /// - Note: Hex channel values use lower-case alphanumerics.
    static func HexChannels(From color: PlatformColor, AddPrefix: Bool = true) -> String
    {
        let Channels = Convert.IntChannels(From: color)
        let RedHex = Channels.red.hex
        let GreenHex = Channels.green.hex
        let BlueHex = Channels.blue.hex
        return "\(AddPrefix ? "0x" : "")\(RedHex)\(GreenHex)\(BlueHex)"
    }
}

// MARK: - Color-Related Extensions

/// Color-related `Int` extensions.
extension Int
{
    /// Clamp the instance `Int` to a valid integer channel value (`0` through `255`).
    func ChannelClamped() -> Int
    {
        return self.Clamped(0, 255)
    }
    
    /// Clamp the instance `Int` to the passed minimum and maximum values.
    func Clamped(_ minValue: Int, _ maxValue: Int) -> Int
    {
        if minValue > maxValue
        {
            print("\(#function): minValue (\(minValue)) > maxValue (\(maxValue)).")
            return self
        }
        if self > maxValue
        {
            return maxValue
        }
        if self < minValue
        {
            return minValue
        }
        return self
    }
}

/// Color-related `Double` extensions.
extension Double
{
    /// Clamp the instance `Double` to a valid double channel value (`0.0` through `1.0`).
    func ChannelClamped() -> Double
    {
        return self.Clamped(0.0, 1.0)
    }
    
    /// Clamp the instance `Double` to the passed minimum and maximum values.
    /// - Parameter minValue: Lowest valid value.
    /// - Parameter maxValue: Greatest valid value.
    /// - Returns:
    func Clamped(_ minValue: Double, _ maxValue: Double) -> Double
    {
        if minValue > maxValue
        {
            print("\(#function): minValue (\(minValue)) > maxValue (\(maxValue)).")
            return self
        }
        if self > maxValue
        {
            return maxValue
        }
        if self < minValue
        {
            return minValue
        }
        return self
    }
}

/// Integer exentions.
extension BinaryInteger
{
    /// Return the instance value as a hex string. Use intended for color channel conversions so assumes (but does not
    /// require) the instance to be in the range `0` to `255`. Adds leading `0`s.
    var hex: String
    {
        String(format: "%02X", Int(self))
    }
}
