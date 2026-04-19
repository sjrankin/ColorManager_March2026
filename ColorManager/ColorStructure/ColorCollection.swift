//
//  ColorCollection.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Contains a collection of logically-grouped colors. Color collections contain colors and/or child color collections.
struct ColorCollection: Identifiable, Equatable
{
    /// ID of the collection.
    let id = UUID()
    /// ID read from the XML `Id` attribute. Nil if the source did not include one.
    let Id: UUID?
    /// Name of the collection. Not required to be unique.
    let Name: String
    /// Optional source for the colors. Usually an URL but not required to be.
    let Source: String?
    /// Optional notes.
    let Notes: String?
    /// Class name (kind of a sub-name).
    let ClassName: String?
    /// Array of colors in the collection. May be nil or empty.
    let Colors: [ColorRecord]?
    /// Optional font to use when displaying color names.
    let Font: String?
    /// Optional nested groups. May be nil or empty.
    let Groups: [ColorGroup]?
    /// Option sub-collections. May be nil or empty.
    let Collections: [ColorCollection]?
}
