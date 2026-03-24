//
//  Colors.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Holds the versioning of the data as well as global flags and all of the colors.
struct Colors: Identifiable, Equatable
{
    /// ID of the data/colors/metadata.
    let id: UUID = UUID()
    /// Default font to use (if available).
    let DefaultFont: String
    /// Enable debugging. Implementation dependent.
    let EnableDebug: Bool
    /// Not used.
    let AutoCapitalize: Bool
    /// Versioning block.
    let Versioning: VersionBlock
    /// All colors. Potentially can be empty or nil, but if that's the case, what's the point?
    let ColorGroups: [ColorGroup]?
}
