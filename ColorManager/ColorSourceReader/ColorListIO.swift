//
//  ColorListIO.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/29/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Imported Color Data Structure

/// Container for imported color data from XML files
struct ImportedColorData
{
    /// Full Colors structure if complete XML found
    let fullColors: Colors?
    /// Color groups if found
    let colorGroups: [ColorGroup]?
    /// Individual color records if found
    let colorRecords: [ColorRecord]?
    /// Type of import performed
    let importType: ImportType
    /// Source file name
    let sourceFileName: String?
}

/// Type of XML structure that was imported
enum ImportType
{
    case fullStructure    // Complete Colors object with versioning
    case groups          // One or more ColorGroups
    case records         // Individual ColorRecords
}

// MARK: - Error Handling

/// Errors that can occur during color list import/export
enum ColorListError: LocalizedError
{
    case invalidXMLStructure
    case unsupportedFormat
    case invalidColorValues(String)
    case fileAccessDenied
    case parsingFailed(String)
    case noColorsDefined
    case invalidHexValue(String)
    case missingRequiredAttribute(String)
    
    var errorDescription: String?
    {
        switch self
        {
            case .invalidXMLStructure:
                return "The XML file structure is invalid or unrecognized."
            case .unsupportedFormat:
                return "This XML format is not supported."
            case .invalidColorValues(let details):
                return "Invalid color values: \(details)"
            case .fileAccessDenied:
                return "Unable to access the selected file."
            case .parsingFailed(let reason):
                return "Failed to parse XML: \(reason)"
            case .noColorsDefined:
                return "No colors were found in the file."
            case .invalidHexValue(let hex):
                return "Invalid hex color value: \(hex)"
            case .missingRequiredAttribute(let attr):
                return "Missing required attribute: \(attr)"
        }
    }
}

// MARK: - Main ColorListIO Class

/// Handles importing and exporting color lists from/to XML files
class ColorListIO
{
    // MARK: - Public Import Methods
    
    /// Import a color list from an XML file using a file picker dialog
    /// - Parameter completion: Called with Result containing ImportedColorData or ColorListError
    static func importColorList(completion: @escaping (Result<ImportedColorData, ColorListError>) -> Void)
    {
        #if os(macOS)
        importColorListMacOS(completion: completion)
        #else
        // For iOS, this should be called from a SwiftUI view using .fileImporter
        // See importColorListSwiftUI() for SwiftUI integration
        completion(.failure(.unsupportedFormat))
        #endif
    }
    
    #if os(macOS)
    /// macOS-specific file picker using NSOpenPanel
    private static func importColorListMacOS(completion: @escaping (Result<ImportedColorData, ColorListError>) -> Void)
    {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.xml]
        panel.message = "Select a color list XML file to import"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else
            {
                completion(.failure(.fileAccessDenied))
                return
            }
            
            do
            {
                let importedData = try parseXMLFile(url: url)
                completion(.success(importedData))
            }
            catch let error as ColorListError
            {
                completion(.failure(error))
            }
            catch
            {
                completion(.failure(.parsingFailed(error.localizedDescription)))
            }
        }
    }
    #endif
    
    /// Parse an XML file from a given URL
    /// - Parameter url: URL to the XML file
    /// - Returns: ImportedColorData structure
    /// - Throws: ColorListError if parsing fails
    static func parseXMLFile(url: URL) throws -> ImportedColorData
    {
        // Try to read the file data with explicit UTF-8 encoding
        guard let data = try? Data(contentsOf: url) else
        {
            throw ColorListError.fileAccessDenied
        }
        
        // Log file encoding info
        if let xmlString = String(data: data, encoding: .utf8) {
            print("📄 XML file size: \(data.count) bytes, \(xmlString.count) characters")
            print("📄 Contains non-ASCII: \(xmlString.contains(where: { !$0.isASCII }))")
        } else {
            print("⚠️ Warning: Could not read file as UTF-8")
        }
        
        let parser = XMLParser(data: data)
        let delegate = ColorListXMLParser()
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        guard parser.parse() else
        {
            if let error = delegate.parsingError
            {
                throw error
            }
            throw ColorListError.parsingFailed("Unknown parsing error")
        }
        
        // Determine what was parsed and return appropriate structure
        if let fullColors = delegate.parsedColors
        {
            return ImportedColorData(
                fullColors: fullColors,
                colorGroups: nil,
                colorRecords: nil,
                importType: .fullStructure,
                sourceFileName: url.lastPathComponent
            )
        }
        else if !delegate.parsedColorGroups.isEmpty
        {
            return ImportedColorData(
                fullColors: nil,
                colorGroups: delegate.parsedColorGroups,
                colorRecords: nil,
                importType: .groups,
                sourceFileName: url.lastPathComponent
            )
        }
        else if !delegate.parsedColorRecords.isEmpty
        {
            return ImportedColorData(
                fullColors: nil,
                colorGroups: nil,
                colorRecords: delegate.parsedColorRecords,
                importType: .records,
                sourceFileName: url.lastPathComponent
            )
        }
        else
        {
            throw ColorListError.noColorsDefined
        }
    }
    
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
    
    // MARK: - Default Version Block Creation
    
    /// Create a default version block for imported colors
    static func createDefaultVersionBlock() -> VersionBlock
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        return VersionBlock(
            FileVersion: FileVersionBlock(
                Date: currentDate,
                Version: "1.0"
            ),
            DataVersion: DataVersionBlock(
                DataDate: currentDate,
                Version: "1.0",
                DataID: UUID()
            ),
            LegalText: LegalTextBlock(
                Copyright: "Imported",
                Rights: "Unknown"
            ),
            SaveData: DataVersionBlock(
                DataDate: currentDate,
                Version: "1.0",
                DataID: UUID()
            )
        )
    }
}

// MARK: - XML Parser Delegate

/// XMLParser delegate that handles parsing color list XML files
class ColorListXMLParser: NSObject, XMLParserDelegate
{
    // Parsed results
    var parsedColors: Colors?
    var parsedColorGroups: [ColorGroup] = []
    var parsedColorRecords: [ColorRecord] = []
    
    // Parsing state
    var parsingError: ColorListError?
    private var currentElement: String = ""
    private var currentAttributes: [String: String] = [:]
    
    // Stack for nested structures
    private var elementStack: [String] = []
    private var colorGroupStack: [ColorGroupBuilder] = []
    private var collectionStack: [ColorCollectionBuilder] = []
    
    // Current builders
    private var currentColorBuilder: ColorRecordBuilder?
    private var currentVersionBuilder: VersionBlockBuilder?
    
    // MARK: - XMLParserDelegate Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?, 
                attributes attributeDict: [String: String] = [:])
    {
        currentElement = elementName
        currentAttributes = attributeDict
        elementStack.append(elementName)
        
        switch elementName.lowercased()
        {
            case "colors":
                // Start of full color structure
                currentVersionBuilder = VersionBlockBuilder()
                
            case "colorgroup":
                let builder = ColorGroupBuilder(attributes: attributeDict)
                colorGroupStack.append(builder)
                
            case "colorcollection":
                let builder = ColorCollectionBuilder(attributes: attributeDict)
                collectionStack.append(builder)
                
            case "color":
                currentColorBuilder = ColorRecordBuilder(attributes: attributeDict)
                
            case "version":
                // Version block start
                break
                
            default:
                break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, 
                namespaceURI: String?, qualifiedName qName: String?)
    {
        elementStack.removeLast()
        
        switch elementName.lowercased()
        {
            case "color":
                if let builder = currentColorBuilder,
                   let colorRecord = builder.build()
                {
                    // Add to appropriate container
                    if !collectionStack.isEmpty
                    {
                        collectionStack[collectionStack.count - 1].colors.append(colorRecord)
                    }
                    else if !colorGroupStack.isEmpty
                    {
                        colorGroupStack[colorGroupStack.count - 1].colors.append(colorRecord)
                    }
                    else
                    {
                        parsedColorRecords.append(colorRecord)
                    }
                }
                currentColorBuilder = nil
                
            case "colorcollection":
                if !collectionStack.isEmpty
                {
                    let builder = collectionStack.removeLast()
                    let collection = builder.build()
                    
                    if !collectionStack.isEmpty
                    {
                        // Add to parent collection
                        collectionStack[collectionStack.count - 1].collections.append(collection)
                    }
                    else if !colorGroupStack.isEmpty
                    {
                        // Add to color group
                        colorGroupStack[colorGroupStack.count - 1].collections.append(collection)
                    }
                }
                
            case "colorgroup":
                if !colorGroupStack.isEmpty
                {
                    let builder = colorGroupStack.removeLast()
                    let group = builder.build()
                    
                    if !colorGroupStack.isEmpty
                    {
                        // Add to parent group
                        colorGroupStack[colorGroupStack.count - 1].groups.append(group)
                    }
                    else
                    {
                        // Top-level group
                        parsedColorGroups.append(group)
                    }
                }
                
            case "colors":
                // Build full Colors structure
                let versionBlock = currentVersionBuilder?.build() ?? ColorListIO.createDefaultVersionBlock()
                parsedColors = Colors(
                    DefaultFont: currentAttributes["defaultFont"] ?? "System",
                    EnableDebug: currentAttributes["enableDebug"] == "true",
                    AutoCapitalize: currentAttributes["autoCapitalize"] == "true",
                    Versioning: versionBlock,
                    ColorGroups: parsedColorGroups.isEmpty ? nil : parsedColorGroups
                )
                
            default:
                break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        parsingError = .parsingFailed(parseError.localizedDescription)
    }
}

// MARK: - Builder Classes

/// Helper class to build ColorRecord from XML attributes
class ColorRecordBuilder
{
    private var name: String
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
    
    // Known attribute names (for detecting unrecognized attributes)
    private static let knownAttributes: Set<String> = [
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
        self.name = attributes["name"] ?? attributes["Name"] ?? "Unnamed"
        self.alternativeName = attributes["aname"] ?? attributes["AName"]
        self.canonical = attributes["canonical"] ?? attributes["Canonical"]
        self.language = attributes["language"] ?? attributes["Language"]
        
        // Log if name contains non-ASCII characters
        if name.contains(where: { !$0.isASCII }) {
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
    
    func build() -> ColorRecord?
    {
        // If no canonical specified, use first defined colorspace
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
        
        return ColorRecord(
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
            Replaces: nil
        )
    }
}

/// Helper class to build ColorGroup from XML
class ColorGroupBuilder
{
    var name: String
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
    var source: String?
    var notes: String?
    var className: String?
    var font: String?
    
    var colors: [ColorRecord] = []
    var collections: [ColorCollection] = []
    
    init(attributes: [String: String])
    {
        self.name = attributes["name"] ?? attributes["Name"] ?? "Unnamed Collection"
        self.source = attributes["source"]
        self.notes = attributes["notes"]
        self.className = attributes["className"] ?? attributes["ClassName"]
        self.font = attributes["font"]
    }
    
    func build() -> ColorCollection
    {
        return ColorCollection(
            Name: name,
            Source: source,
            Notes: notes,
            ClassName: className,
            Colors: colors.isEmpty ? nil : colors,
            Font: font,
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

// MARK: - SwiftUI Integration

/// SwiftUI view modifier for importing color lists
struct ColorListImporterModifier: ViewModifier
{
    @Binding var isPresented: Bool
    let onImport: (Result<ImportedColorData, ColorListError>) -> Void
    
    func body(content: Content) -> some View
    {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [.xml],
                allowsMultipleSelection: false
            ) { result in
                switch result
                {
                    case .success(let urls):
                        guard let url = urls.first else
                        {
                            onImport(.failure(.fileAccessDenied))
                            return
                        }
                        
                        do
                        {
                            let importedData = try ColorListIO.parseXMLFile(url: url)
                            onImport(.success(importedData))
                        }
                        catch let error as ColorListError
                        {
                            onImport(.failure(error))
                        }
                        catch
                        {
                            onImport(.failure(.parsingFailed(error.localizedDescription)))
                        }
                        
                    case .failure(let error):
                        onImport(.failure(.parsingFailed(error.localizedDescription)))
                }
            }
    }
}

extension View
{
    /// Presents a file importer for color list XML files
    /// - Parameters:
    ///   - isPresented: Binding to control presentation
    ///   - onImport: Closure called with import result
    func colorListImporter(isPresented: Binding<Bool>, 
                          onImport: @escaping (Result<ImportedColorData, ColorListError>) -> Void) -> some View
    {
        modifier(ColorListImporterModifier(isPresented: isPresented, onImport: onImport))
    }
}
