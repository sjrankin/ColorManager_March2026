//
//  ColorSpaceUtilities.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension ColorListIO
{
    // MARK: - Color Space Parsing Utilities
    
    /// Create a HexRecord from a hex string
    /// - Parameter hexString: Hex color value (with or without # prefix)
    /// - Returns: HexRecord if valid, nil otherwise
    static func createHexRecord(from hexString: String) -> HexRecord?
    {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#")
        {
            hex.remove(at: hex.startIndex)
        }
        
        // Validate it's a valid hex string using radix 16
        guard let _ = Int(hex, radix: 16) else
        {
            return nil
        }
        
        // Ensure it's 6 or 8 characters (RGB or RGBA)
        guard hex.count == 6 || hex.count == 8 else
        {
            return nil
        }
        
        return HexRecord(HexValue: hex.uppercased())
    }
    
    // MARK: - Color Space Conversion Utilities
    
    /// Convert RGB to Hex
    static func rgbToHex(r: Int, g: Int, b: Int) -> String?
    {
        guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) else
        {
            return nil
        }
        return String(format: "%02X%02X%02X", r, g, b)
    }
    
    /// Convert CMYK to RGB
    static func cmykToRGB(c: Double, m: Double, y: Double, k: Double) -> (r: Int, g: Int, b: Int)?
    {
        guard (0...100).contains(c) && (0...100).contains(m) &&
                (0...100).contains(y) && (0...100).contains(k) else
        {
            return nil
        }
        
        // Convert percentages to 0-1 range
        let cNorm = c / 100.0
        let mNorm = m / 100.0
        let yNorm = y / 100.0
        let kNorm = k / 100.0
        
        // CMYK to RGB conversion
        let r = Int((1.0 - cNorm) * (1.0 - kNorm) * 255.0)
        let g = Int((1.0 - mNorm) * (1.0 - kNorm) * 255.0)
        let b = Int((1.0 - yNorm) * (1.0 - kNorm) * 255.0)
        
        return (r, g, b)
    }
    
    /// Convert HSL to RGB
    static func hslToRGB(h: Double, s: Double, l: Double) -> (r: Int, g: Int, b: Int)?
    {
        guard (0...360).contains(h) && (0...100).contains(s) && (0...100).contains(l) else
        {
            return nil
        }
        
        let hNorm = h / 360.0
        let sNorm = s / 100.0
        let lNorm = l / 100.0
        
        let c = (1.0 - abs(2.0 * lNorm - 1.0)) * sNorm
        let x = c * (1.0 - abs((hNorm * 6.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = lNorm - c / 2.0
        
        var r = 0.0, g = 0.0, b = 0.0
        
        let hSextant = Int(hNorm * 6.0)
        switch hSextant {
            case 0: (r, g, b) = (c, x, 0)
            case 1: (r, g, b) = (x, c, 0)
            case 2: (r, g, b) = (0, c, x)
            case 3: (r, g, b) = (0, x, c)
            case 4: (r, g, b) = (x, 0, c)
            default: (r, g, b) = (c, 0, x)
        }
        
        return (Int((r + m) * 255), Int((g + m) * 255), Int((b + m) * 255))
    }
    
    /// Convert HSB (HSV) to RGB
    static func hsbToRGB(h: Double, s: Double, b: Double) -> (r: Int, g: Int, b: Int)?
    {
        guard (0...360).contains(h) && (0...100).contains(s) && (0...100).contains(b) else
        {
            return nil
        }
        
        let hNorm = h / 360.0
        let sNorm = s / 100.0
        let bNorm = b / 100.0
        
        let c = bNorm * sNorm
        let x = c * (1.0 - abs((hNorm * 6.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = bNorm - c
        
        var r = 0.0, g = 0.0, b = 0.0
        
        let hSextant = Int(hNorm * 6.0)
        switch hSextant {
            case 0: (r, g, b) = (c, x, 0)
            case 1: (r, g, b) = (x, c, 0)
            case 2: (r, g, b) = (0, c, x)
            case 3: (r, g, b) = (0, x, c)
            case 4: (r, g, b) = (x, 0, c)
            default: (r, g, b) = (c, 0, x)
        }
        
        return (Int((r + m) * 255), Int((g + m) * 255), Int((b + m) * 255))
    }
    
    /// Convert LAB to RGB (approximate conversion)
    static func labToRGB(l: Double, a: Double, b: Double) -> (r: Int, g: Int, b: Int)?
    {
        guard (0...100).contains(l) && (-128...127).contains(a) && (-128...127).contains(b) else
        {
            return nil
        }
        
        // LAB to XYZ
        var y = (l + 16.0) / 116.0
        var x = a / 500.0 + y
        var z = y - b / 200.0
        
        let delta = 6.0 / 29.0
        
        x = x > delta ? pow(x, 3) : 3 * delta * delta * (x - 4.0 / 29.0)
        y = y > delta ? pow(y, 3) : 3 * delta * delta * (y - 4.0 / 29.0)
        z = z > delta ? pow(z, 3) : 3 * delta * delta * (z - 4.0 / 29.0)
        
        // D65 illuminant
        x *= 0.95047
        y *= 1.00000
        z *= 1.08883
        
        // XYZ to RGB (sRGB)
        var r = x *  3.2406 + y * -1.5372 + z * -0.4986
        var g = x * -0.9689 + y *  1.8758 + z *  0.0415
        var bVal = x *  0.0557 + y * -0.2040 + z *  1.0570
        
        // Gamma correction
        r = r > 0.0031308 ? 1.055 * pow(r, 1.0/2.4) - 0.055 : 12.92 * r
        g = g > 0.0031308 ? 1.055 * pow(g, 1.0/2.4) - 0.055 : 12.92 * g
        bVal = bVal > 0.0031308 ? 1.055 * pow(bVal, 1.0/2.4) - 0.055 : 12.92 * bVal
        
        // Clamp to valid range
        r = max(0, min(1, r))
        g = max(0, min(1, g))
        bVal = max(0, min(1, bVal))
        
        return (Int(r * 255), Int(g * 255), Int(bVal * 255))
    }
    
    /// Create an RGBRecord from integer values
    static func createRGBRecord(r: Int, g: Int, b: Int) -> RGBRecord?
    {
        guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) else
        {
            return nil
        }
        return RGBRecord(r: r, g: g, b: b)
    }
    
    /// Create an HSLRecord from double values
    static func createHSLRecord(h: Double, s: Double, l: Double) -> HSLRecord?
    {
        guard (0...360).contains(h) && (0...100).contains(s) && (0...100).contains(l) else
        {
            return nil
        }
        return HSLRecord(h: h, s: s, l: l)
    }
    
    /// Create an HSBRecord from double values
    static func createHSBRecord(h: Double, s: Double, b: Double) -> HSBRecord?
    {
        guard (0...360).contains(h) && (0...100).contains(s) && (0...100).contains(b) else
        {
            return nil
        }
        return HSBRecord(h: h, s: s, b: b)
    }
    
    /// Create a CMYKRecord from double values (0-100)
    static func createCMYKRecord(c: Double, m: Double, y: Double, k: Double) -> CMYKRecord?
    {
        guard (0...100).contains(c) && (0...100).contains(m) &&
                (0...100).contains(y) && (0...100).contains(k) else
        {
            return nil
        }
        return CMYKRecord(c: c, y: y, m: m, k: k)
    }
    
    /// Create a LABRecord from double values
    static func createLABRecord(l: Double, a: Double, b: Double) -> LABRecord?
    {
        guard (0...100).contains(l) && (-128...127).contains(a) && (-128...127).contains(b) else
        {
            return nil
        }
        return LABRecord(l: l, a: a, b: b)
    }
}
