//
//  ColorCollection.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

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
