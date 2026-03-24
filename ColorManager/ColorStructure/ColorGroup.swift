//
//  ColorGroup.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct ColorGroup: Identifiable, Equatable
{
    let id = UUID()
    let Name: String
    let ShortName: String?
    let ClassName: String?
    let Alias: String?
    let Source: [String]?
    let Legal: String?
    let TestGroup: Bool?
    let Notes: String?
    let Colors: [ColorRecord]?
    let Groups: [ColorGroup]?
    let Collections: [ColorCollection]?
}
