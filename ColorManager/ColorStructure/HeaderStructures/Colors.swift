//
//  Colors.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct Colors: Identifiable, Equatable
{
    let id: UUID = UUID()
    let DefaultFont: String
    let EnableDebug: Bool
    let AutoCapitalize: Bool
    let Versioning: VersionBlock
    let ColorGroups: [ColorGroup]?
}
