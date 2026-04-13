//
//  ColorListXMLParser.swift
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
