//
//  ColorGroup.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Group of colors for logically similar colors. Can also contains child color groups and color collections.
struct ColorGroup: Identifiable, Equatable
{
    /// ID of the color group.
    let id = UUID()
    /// Name of the color group.
    let Name: String
    /// Optional short name of the color group. Assigned by the group's author if the long name is too long.
    let ShortName: String?
    /// Optional class name of the group.
    let ClassName: String?
    /// Optional alias of the group.
    let Alias: String?
    /// Optional array of sources for the colors. May be any string but usually URLs.
    let Source: [String]?
    /// Optional legal information for the colors.
    let Legal: String?
    /// Optional flag for testing.
    let TestGroup: Bool?
    /// Optional notes for the group.
    let Notes: String?
    /// Array of colors. May be empty or nil.
    let Colors: [ColorRecord]?
    /// Array of color groups. May be empty or nil.
    let Groups: [ColorGroup]?
    /// Array of color collections. May be empty or nil.
    let Collections: [ColorCollection]?
}
