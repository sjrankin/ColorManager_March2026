//
//  ColorRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/22/26.
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

struct ColorCollection: Identifiable, Equatable
{
    let id = UUID()
    let Name: String
    let Source: String?
    let Notes: String?
    let ClassName: String?
    let Colors: [ColorRecord]?
    let Font: String?
}

struct ColorRecord: Identifiable, Equatable
{
    let id = UUID()
    let Name: String //Name
    let AlternativeNames: [String]? //Names
    let AlternativeName: String? //AName
    let Canonical: String? //The canonical colorspace.
    let Tags: [String]?
    let Language: String?
    let HexValue: String
    let RGB: RGBRecord?
    let HSL: HSLRecord?
    let CMYK: CMYKRecord?
    let LAB: LABRecord?
    let Variant: [ColorVariant]?
}

struct ColorVariant: Identifiable, Equatable
{
    let id = UUID()
    let HexValue: String
}

struct RGBRecord: Identifiable, Equatable
{
    let id = UUID()
    let r: Int
    let g: Int
    let b: Int
}

struct HSLRecord: Identifiable, Equatable
{
    let id = UUID()
    let h: Double
    let s: Double
    let l: Double
}

struct CMYKRecord: Identifiable, Equatable
{
    let id = UUID()
    let c: Double
    let y: Double
    let m: Double
    let k: Double
}

struct LABRecord: Identifiable, Equatable
{
    let id = UUID()
    let l: Double
    let a: Double
    let b: Double
}
