//
//  ColorTerms.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation

//https://en.wikipedia.org/wiki/ISCC%E2%80%93NBS_system
//https://en.wikipedia.org/wiki/Color_Naming_System
//https://www.munsellcolorscienceforpainters.com/ISCCNBS/ISCCNBSSystem.html
class ColorTerms
{
    static func Initialize()
    {
        ColorTheory = BaseColorTheory
        Brightness = BasicBrightness
        Intensity = BasicIntensity
        Chroma = BasicChroma
        Tint = BasicTint
        Saturation = BasicSaturation
        Ish = BasicIsh
        Generic = BasicGeneric
    }
    
    static func Reset()
    {
        Initialize()
    }
    
    // MARK: - General modifiers
    
    static let BasicGeneric: [String] =
    [
        "Vivid",
        "Brilliant",
        "Strong",
        "Deep",
        "Very",
        "Moderate"
    ]
    
    static var Generic = [String]()
    
        // MARK: - Ish Colors
    
    static let BasicIsh: [String] =
    [
        "Reddish",
        "Greenish",
        "Yellowish",
        "Bluish",
        "Greenish",
        "Purplish",
        "Brownish"
    ]
    
    static var Ish = [String]()
    
    // MARK: - Color Theory
    
    static let BaseColorTheory: [String] =
    [
        "Warm",
        "Cool"
    ]
    
    static var ColorTheory = [String]()
    
    // MARK: - Saturation
    
    static let BasicSaturation: [String] =
    [
        "Saturated",
        "Desaturated",
        "Deep",
        "Royal",
        "Pastel",
        "Neon",
        "Fluorescent"
        ]
    
    static var Saturation = [String]()
    
    // MARK: - Brightness
    
    static let BasicBrightness: [String] =
    [
        "Bright",
        "Dim",
        "Dark",
        "Light"
    ]
    
    static var Brightness = [String]()
    
    // MARK: - Intensity
    
    static let BasicIntensity: [String] =
    [
        "Soft",
        "Hard",
        "Bright",
        "Dark",
        "Weak",
        "Dull"
    ]
    
    static var Intensity = [String]()
    
    // MARK: - Chroma
    
    static let BasicChroma: [String] =
    [
        "Warm",
        "Cool",
        "Cooling",
        "Warming"
    ]
    
    static var Chroma = [String]()
    
    // MARK: - Tint
    
    static let BasicTint: [String] =
    [
        "Light",
        "Bright",
        "Shine",
"Tint"
        ]
    
    static var Tint = [String]()
}
