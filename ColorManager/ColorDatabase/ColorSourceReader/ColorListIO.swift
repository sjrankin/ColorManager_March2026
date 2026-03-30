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
        guard let parser = XMLParser(contentsOf: url) else
        {
            throw ColorListError.fileAccessDenied
        }
        
        let delegate = ColorListXMLParser()
        parser.delegate = delegate
        
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
    
    init(attributes: [String: String])
    {
        self.name = attributes["name"] ?? attributes["Name"] ?? "Unnamed"
        self.alternativeName = attributes["aname"] ?? attributes["AName"]
        self.canonical = attributes["canonical"]
        self.language = attributes["language"]
        
        // Parse alternative names (comma-separated)
        if let names = attributes["names"] ?? attributes["Names"]
        {
            self.alternativeNames = names.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
        
        // Parse tags (comma-separated)
        if let tagsString = attributes["tags"]
        {
            self.tags = tagsString.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        }
        
        // Parse color spaces in order to determine first defined
        parseColorSpaces(from: attributes)
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
        
        // Check RGB
        if let rStr = attributes["r"], let gStr = attributes["g"], let bStr = attributes["b"],
           let r = Int(rStr), let g = Int(gStr), let b = Int(bStr)
        {
            rgbRecord = ColorListIO.createRGBRecord(r: r, g: g, b: b)
            if rgbRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "RGB"
            }
        }
        
        // Check HSL
        if let hStr = attributes["h"], let sStr = attributes["s"], let lStr = attributes["l"],
           let h = Double(hStr), let s = Double(sStr), let l = Double(lStr)
        {
            hslRecord = ColorListIO.createHSLRecord(h: h, s: s, l: l)
            if hslRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "HSL"
            }
        }
        
        // Check HSB (only if HSL wasn't defined - both use h,s)
        if hslRecord == nil,
           let hStr = attributes["h"], let sStr = attributes["s"], let bStr = attributes["b"],
           let h = Double(hStr), let s = Double(sStr), let b = Double(bStr)
        {
            hsbRecord = ColorListIO.createHSBRecord(h: h, s: s, b: b)
            if hsbRecord != nil && firstDefinedColorSpace == nil
            {
                firstDefinedColorSpace = "HSB"
            }
        }
        
        // Check CMYK
        if let cStr = attributes["c"], let mStr = attributes["m"], 
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
        
        // Check LAB
        if let lStr = attributes["L"], let aStr = attributes["a"], let bStr = attributes["b"],
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
        
        return ColorRecord(
            Name: name,
            AlternativeNames: alternativeNames,
            AlternativeName: alternativeName,
            Canonical: finalCanonical,
            Tags: tags,
            Language: language,
            Hex: hexRecord,
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
