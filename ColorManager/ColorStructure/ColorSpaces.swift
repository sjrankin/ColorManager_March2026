//
//  ColorSpaces.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

enum ColorSpaces: String
{
    case RGB = "RGB"
    case HSL = "HSL"
    case HSB = "HSB"
    case CMYK = "CMYK"
    case LAB = "LAB"
    case Hex = "HEX"
    
    static func from(rawValue: String?) -> ColorSpaces?
    {
        guard let raw = rawValue else
        {
            return nil
        }
        switch raw.uppercased()
        {
            case "HEX":
                return .Hex
            case "RGB":
                return .RGB
            case "HSL":
                return .HSL
            case "HSB":
                return .HSB
            case "CMYK":
                return .CMYK
            case "LAB":
                return .LAB
            default:
                return nil
        }
    }
}
