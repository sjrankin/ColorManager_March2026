//
//  ColorBuilders.swift
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

// MARK: - Builder Classes

/// Helper class to build ColorRecord from XML attributes
class ColorRecordBuilder
{
    var name: String
    private var alternativeName: String?
    private var alternativeNames: [String]?
    private var canonical: String?
    private var tags: [String]?
    private var language: String?
    
    private var hexRecord: HexRecord?
    private var rgbRecord: RGBRecord?
    private var hslRecord: HSLRecord?
    private var hsbRecord: HSBRecord?
    private var cmykRecord: CMYKRecord?
    private var labRecord: LABRecord?
    
    private var firstDefinedColorSpace: String?
    private var xmlDefinition: String?

    private var sourceId: UUID?

    // Known attribute names (for detecting unrecognized attributes)
    private static let knownAttributes: Set<String> = [
        "id", "Id",
        "name", "Name",
        "aname", "AName",
        "names", "Names", "anames", "ANames",
        "canonical", "Canonical",
        "tags", "Tags",
        "language", "Language",
        "hex", "Hex",
        "RGB", "rgb", "r", "g", "b",
        "CMYK", "cmyk", "c", "m", "y", "k",
        "HSL", "hsl", "h", "s", "l",
        "HSB", "hsb", "HSV", "hsv",
        "LAB", "lab", "L", "a",
        "variant",
        "replaces"
    ]

    init(attributes: [String: String])
    {
        if let idStr = attributes["Id"] ?? attributes["id"] {
            self.sourceId = UUID(uuidString: idStr)
        }
        self.name = attributes["name"] ?? attributes["Name"] ?? ""
        self.alternativeName = attributes["aname"] ?? attributes["AName"]
        self.canonical = attributes["canonical"] ?? attributes["Canonical"]
        self.language = attributes["language"] ?? attributes["Language"]
        
        // Log if name contains non-ASCII characters
        if name.contains(where: { !$0.isASCII })
        {
            print("🌏 Parsing color with non-ASCII name: '\(name)'")
        }
        
        // Parse alternative names (comma-separated) - treat both "Names" and "ANames" as alternative names
        if let names = attributes["names"] ?? attributes["Names"] ?? attributes["anames"] ?? attributes["ANames"]
        {
            self.alternativeNames = names.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
        
        // Parse tags (comma-separated)
        if let tagsString = attributes["tags"] ?? attributes["Tags"]
        {
            self.tags = tagsString.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
        
        // Check for unrecognized attributes
        logUnrecognizedAttributes(attributes)

        // Parse color spaces in order to determine first defined
        parseColorSpaces(from: attributes)

        // Reconstruct the raw XML element string from attributes.
        // Name is placed first; remaining attributes follow in sorted order.
        var attrParts: [String] = []
        if let nameVal = attributes["name"] ?? attributes["Name"] {
            attrParts.append("Name=\"\(nameVal)\"")
        }
        let otherAttrs = attributes
            .filter { $0.key.lowercased() != "name" }
            .sorted { $0.key < $1.key }
        for (key, value) in otherAttrs {
            attrParts.append("\(key)=\"\(value)\"")
        }
        let attrString = attrParts.isEmpty ? "" : " \(attrParts.joined(separator: " "))"
        xmlDefinition = "<Color\(attrString)/>"
    }
    
    /// Log any unrecognized attributes to help identify parsing issues
    private func logUnrecognizedAttributes(_ attributes: [String: String])
    {
        let unrecognized = attributes.keys.filter { !ColorRecordBuilder.knownAttributes.contains($0) }
        
        if !unrecognized.isEmpty
        {
            print("⚠️ Unrecognized attributes in color '\(name)': \(unrecognized.sorted().joined(separator: ", "))")
            for attr in unrecognized.sorted()
            {
                print("   - \(attr) = \"\(attributes[attr] ?? "")\"")
            }
        }
    }
    
    private func parseColorSpaces(from attributes: [String: String])
    {
        // Check Hex
        if let hex = attributes["hex"] ?? attributes["Hex"]
        {
            hexRecord = ColorListIO.createHexRecord(from: hex)
            if hexRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "HEX"
            }
        }
        
        // Check RGB - handle both comma-separated and individual attributes
        var rgbParsed = false
        
        // Try comma-separated format first: RGB="255,217,15"
        if let rgbString = attributes["RGB"] ?? attributes["rgb"]
        {
            let components = rgbString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 3,
               let r = Int(components[0]),
               let g = Int(components[1]),
               let b = Int(components[2])
            {
                rgbRecord = ColorListIO.createRGBRecord(r: r, g: g, b: b)
                if rgbRecord != nil && firstDefinedColorSpace == nil
                {
                    firstDefinedColorSpace = "RGB"
                }
                rgbParsed = true
            }
        }
        
        // Try individual attributes: r="255" g="217" b="15"
        if !rgbParsed,
           let rStr = attributes["r"], let gStr = attributes["g"], let bStr = attributes["b"],
           let r = Int(rStr), let g = Int(gStr), let b = Int(bStr)
        {
            rgbRecord = ColorListIO.createRGBRecord(r: r, g: g, b: b)
            if rgbRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "RGB"
            }
        }
        
        // Check CMYK - handle both comma-separated and individual attributes
        var cmykParsed = false
        
        // Try comma-separated format: CMYK="0,100,100,0"
        if let cmykString = attributes["CMYK"] ?? attributes["cmyk"]
        {
            let components = cmykString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 4,
               let c = Double(components[0]),
               let m = Double(components[1]),
               let y = Double(components[2]),
               let k = Double(components[3])
            {
                cmykRecord = ColorListIO.createCMYKRecord(c: c, m: m, y: y, k: k)
                if cmykRecord != nil && firstDefinedColorSpace == nil
                {
                    firstDefinedColorSpace = "CMYK"
                }
                cmykParsed = true
            }
        }
        
        // Try individual attributes
        if !cmykParsed,
           let cStr = attributes["c"], let mStr = attributes["m"],
           let yStr = attributes["y"], let kStr = attributes["k"],
           let c = Double(cStr), let m = Double(mStr),
           let y = Double(yStr), let k = Double(kStr)
        {
            cmykRecord = ColorListIO.createCMYKRecord(c: c, m: m, y: y, k: k)
            if cmykRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "CMYK"
            }
        }
        
        // Check HSL - handle both comma-separated and individual attributes
        var hslParsed = false
        
        // Try comma-separated format: HSL="120,100,50"
        if let hslString = attributes["HSL"] ?? attributes["hsl"]
        {
            let components = hslString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 3,
               let h = Double(components[0]),
               let s = Double(components[1]),
               let l = Double(components[2])
            {
                hslRecord = ColorListIO.createHSLRecord(h: h, s: s, l: l)
                if hslRecord != nil && firstDefinedColorSpace == nil
                {
                    firstDefinedColorSpace = "HSL"
                }
                hslParsed = true
            }
        }
        
        // Try individual attributes
        if !hslParsed,
           let hStr = attributes["h"], let sStr = attributes["s"], let lStr = attributes["l"],
           let h = Double(hStr), let s = Double(sStr), let l = Double(lStr)
        {
            hslRecord = ColorListIO.createHSLRecord(h: h, s: s, l: l)
            if hslRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "HSL"
            }
        }
        
        // Check HSB (only if HSL wasn't defined - both use h,s)
        var hsbParsed = false
        
        // Try comma-separated format: HSB="120,100,50"
        if hslRecord == nil,
           let hsbString = attributes["HSB"] ?? attributes["hsb"] ?? attributes["HSV"] ?? attributes["hsv"]
        {
            let components = hsbString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 3,
               let h = Double(components[0]),
               let s = Double(components[1]),
               let b = Double(components[2])
            {
                hsbRecord = ColorListIO.createHSBRecord(h: h, s: s, b: b)
                if hsbRecord != nil && firstDefinedColorSpace == nil
                {
                    firstDefinedColorSpace = "HSB"
                }
                hsbParsed = true
            }
        }
        
        // Try individual attributes (only if HSL wasn't defined)
        if !hsbParsed && hslRecord == nil,
           let hStr = attributes["h"], let sStr = attributes["s"], let bStr = attributes["b"],
           let h = Double(hStr), let s = Double(sStr), let b = Double(bStr)
        {
            hsbRecord = ColorListIO.createHSBRecord(h: h, s: s, b: b)
            if hsbRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "HSB"
            }
        }
        
        // Check LAB - handle both comma-separated and individual attributes
        var labParsed = false
        
        // Try comma-separated format: LAB="53,-80,67"
        if let labString = attributes["LAB"] ?? attributes["lab"]
        {
            let components = labString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 3,
               let l = Double(components[0]),
               let a = Double(components[1]),
               let b = Double(components[2])
            {
                labRecord = ColorListIO.createLABRecord(l: l, a: a, b: b)
                if labRecord != nil && firstDefinedColorSpace == nil
                {
                    firstDefinedColorSpace = "LAB"
                }
                labParsed = true
            }
        }
        
        // Try individual attributes
        if !labParsed,
           let lStr = attributes["L"], let aStr = attributes["a"], let bStr = attributes["b"],
           let l = Double(lStr), let a = Double(aStr), let b = Double(bStr)
        {
            labRecord = ColorListIO.createLABRecord(l: l, a: a, b: b)
            if labRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "LAB"
            }
        }
    }
    
    /// Build a color record based on `init` data.
    /// - Returns: A `ColorRecord` on success, `nil` on error.
    func build() -> ColorRecord?
    {
        // If no canonical colorspace specified, use first defined colorspace
        let finalCanonical = canonical ?? firstDefinedColorSpace
        
        // Auto-generate hex if not present, using priority order: RGB, CMYK, HSL, HSB, LAB
        var finalHexRecord = hexRecord
        
        if finalHexRecord == nil
        {
            var rgbValues: (r: Int, g: Int, b: Int)?
            
            // Try RGB first
            if let rgb = rgbRecord
            {
                rgbValues = (rgb.r, rgb.g, rgb.b)
            }
            // Try CMYK
            else if let cmyk = cmykRecord
            {
                rgbValues = ColorListIO.cmykToRGB(c: cmyk.c, m: cmyk.m, y: cmyk.y, k: cmyk.k)
            }
            // Try HSL
            else if let hsl = hslRecord
            {
                rgbValues = ColorListIO.hslToRGB(h: hsl.h, s: hsl.s, l: hsl.l)
            }
            // Try HSB
            else if let hsb = hsbRecord
            {
                rgbValues = ColorListIO.hsbToRGB(h: hsb.h, s: hsb.s, b: hsb.b)
            }
            // Try LAB
            else if let lab = labRecord
            {
                rgbValues = ColorListIO.labToRGB(l: lab.l, a: lab.a, b: lab.b)
            }
            
            // Convert RGB to hex if we got values
            if let rgb = rgbValues,
               let hexString = ColorListIO.rgbToHex(r: rgb.r, g: rgb.g, b: rgb.b)
            {
                finalHexRecord = HexRecord(HexValue: hexString)
                print("📝 Auto-generated hex '\(hexString)' for color '\(name)' from available color space")
            }
        }
        
        if name.contains(where: { !$0.isASCII })
        {
            print("Non-ASCII color name.")
        }
        
        let FinalColor = ColorRecord(Id: sourceId,
            Name: name,
            AlternativeNames: alternativeNames,
            AlternativeName: alternativeName,
            Canonical: finalCanonical,
            Tags: tags,
            Language: language,
            Hex: finalHexRecord,
            RGB: rgbRecord,
            HSL: hslRecord,
            HSB: hsbRecord,
            CMYK: cmykRecord,
            LAB: labRecord,
            Variant: nil,
            Replaces: nil,
            XMLDefinition: xmlDefinition)
        
        return FinalColor
    }
}

/// Helper class to build ColorGroup from XML
class ColorGroupBuilder
{
    var name: String
    var sourceId: UUID?
    var shortName: String?
    var className: String?
    var alias: String?
    var source: [String]?
    var legal: String?
    var testGroup: Bool?
    var notes: String?

    var colors: [ColorRecord] = []
    var groups: [ColorGroup] = []
    var collections: [ColorCollection] = []

    init(attributes: [String: String])
    {
        if let idStr = attributes["Id"] ?? attributes["id"] {
            self.sourceId = UUID(uuidString: idStr)
        }
        self.name = attributes["name"] ?? attributes["Name"] ?? "Unnamed Group"
        self.shortName = attributes["shortName"] ?? attributes["ShortName"]
        self.className = attributes["className"] ?? attributes["ClassName"]
        self.alias = attributes["alias"]
        self.legal = attributes["legal"]
        self.notes = attributes["notes"]
        self.testGroup = (attributes["testGroup"] ?? attributes["TestGroup"]) == "true"

        if let sourceStr = attributes["source"]
        {
            self.source = sourceStr.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
    }

    func build() -> ColorGroup
    {
        return ColorGroup(
            Id: sourceId,
            Name: name,
            ShortName: shortName,
            ClassName: className,
            Alias: alias,
            Source: source,
            Legal: legal,
            TestGroup: testGroup,
            Notes: notes,
            Colors: colors.isEmpty ? nil : colors,
            Groups: groups.isEmpty ? nil : groups,
            Collections: collections.isEmpty ? nil : collections
        )
    }
}

/// Helper class to build ColorCollection from XML
class ColorCollectionBuilder
{
    var name: String
    var sourceId: UUID?
    var source: String?
    var notes: String?
    var className: String?
    var font: String?

    var colors: [ColorRecord] = []
    var groups: [ColorGroup] = []
    var collections: [ColorCollection] = []

    init(attributes: [String: String])
    {
        if let idStr = attributes["Id"] ?? attributes["id"] {
            self.sourceId = UUID(uuidString: idStr)
        }
        self.name = attributes["name"] ?? attributes["Name"] ?? "Unnamed Collection"
        self.source = attributes["source"]
        self.notes = attributes["notes"]
        self.className = attributes["className"] ?? attributes["ClassName"]
        self.font = attributes["font"]
    }

    func build() -> ColorCollection
    {
        return ColorCollection(
            Id: sourceId,
            Name: name,
            Source: source,
            Notes: notes,
            ClassName: className,
            Colors: colors.isEmpty ? nil : colors,
            Font: font,
            Groups: groups.isEmpty ? nil : groups,
            Collections: collections.isEmpty ? nil : collections
        )
    }
}

/// Helper class to build VersionBlock from XML
class VersionBlockBuilder
{
    func build() -> VersionBlock
    {
        return ColorListIO.createDefaultVersionBlock()
    }
}
