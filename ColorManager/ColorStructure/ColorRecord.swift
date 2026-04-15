//
//  ColorRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
//

import Foundation

/// Contains a single color. The color may have multiple specifications in different color spaces, as well as color variants.
/// - Note: Some colors with multiple colorspace defintions have the `Canonical` value present, which is nothing more than the
/// name of the color space (eg, "Hex" or "CMYK") that should be treated as the authoritative color space. When there are multiple
/// colorspaces present but no `Canonical` value, the authoritative colorspace is determined in this order of the first non-empty
/// colorspace: `Hex`, `RGB`, `HSL`, `HSB`, `CMYK`, `LAB`.
/// - Note: To edit an existing color, the caller must create a new `ColorRecord` based on the color the user wants to edit. Helper
/// functions are provided for that.
struct ColorRecord: Identifiable, Equatable
{
    let id = UUID()
    let Name: String //Name
    let AlternativeNames: [String]? //Names
    let AlternativeName: String? //AName
    let Canonical: String? //The canonical colorspace.
    let Tags: [String]?
    let Language: String?
    let Hex: HexRecord?
    let RGB: RGBRecord?
    let HSL: HSLRecord?
    let HSB: HSBRecord?
    let CMYK: CMYKRecord?
    let LAB: LABRecord?
    let Variant: [ColorVariant]?
    var Replaces: UUID?
    /// Raw XML element string as read from the source file (e.g. `<Color Name="Red" Hex="ff0000"/>`).
    let XMLDefinition: String?
    
    var CanonicalColorValue: String?
    {
        get
        {
            if let CanonicalColorSpace = ColorSpaces.from(rawValue: self.Canonical)
            {
                if HasColorSpaceColor(CanonicalColorSpace)
                {
                    switch CanonicalColorSpace
                    {
                        case .Hex: return self.Hex?.AsString()
                        case .CMYK: return self.CMYK?.AsString()
                        case .HSB: return self.HSB?.AsString()
                        case .HSL: return self.HSL?.AsString()
                        case .LAB: return self.LAB?.AsString()
                        case .RGB: return self.RGB?.AsString()
                    }
                }
            }
            //If we are here, there is no canonical color space or the canonical colorspace is nil.
            //Return the first non-nil value in this order: Hex, RGB, HSL, HSB, CMYK, LAB.
            if let HexValue = self.Hex?.AsString() { return HexValue }
            if let RGBValue = self.RGB?.AsString() { return RGBValue }
            if let HSLValue = self.HSL?.AsString() { return HSLValue }
            if let HSBValue = self.HSB?.AsString() { return HSBValue }
            if let CMYKValue = self.CMYK?.AsString() { return CMYKValue }
            if let LABValue = self.LAB?.AsString() { return LABValue }
            
            return nil
        }
    }
    
    var CanonicalColorRecord: ColorRecordToString?
    {
        get
        {
            if let CanonicalColorSpace = ColorSpaces.from(rawValue: self.Canonical)
            {
                if HasColorSpaceColor(CanonicalColorSpace)
                {
                    switch CanonicalColorSpace
                    {
                        case .Hex: return self.Hex
                        case .CMYK: return self.CMYK
                        case .HSB: return self.HSB
                        case .HSL: return self.HSL
                        case .LAB: return self.LAB
                        case .RGB: return self.RGB
                    }
                }
            }
            //If we are here, there is no canonical color space or the canonical colorspace is nil.
            //Return the first non-nil record in this order: Hex, RGB, HSL, HSB, CMYK, LAB.
            if let HexRecord = self.Hex { return HexRecord}
            if let RGBRecord = self.RGB { return RGBRecord}
            if let HSLRecord = self.HSL { return HSLRecord}
            if let HSBRecord = self.HSB { return HSBRecord}
            if let CMYKRecord = self.CMYK { return CMYKRecord}
            if let LABRecord = self.LAB { return LABRecord}
            
            return nil
        }
    }
    
    func HasColorSpaceColor(_ ColorSpace: ColorSpaces) -> Bool
    {
        switch ColorSpace
        {
            case .Hex: return self.Hex != nil
            case .CMYK: return self.CMYK != nil
            case .HSB: return self.HSB != nil
            case .HSL: return self.HSL != nil
            case .LAB: return self.LAB != nil
            case .RGB: return self.RGB != nil
        }
    }
    
    func MakeReplaceable() -> ColorRecord
    {
        var NewColor = self
        NewColor.Replaces = self.id
        return NewColor
    }
}










