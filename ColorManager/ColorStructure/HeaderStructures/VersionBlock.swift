//
//  VersionBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Contains versioning and other meta data for the colors.
struct VersionBlock: Equatable
{
    /// ID of the version block.
    let id: UUID = UUID()
    /// File versioning data.
    let FileVersion: FileVersionBlock
    /// Data versioning.
    let DataVersion: DataVersionBlock
    /// Legal text.
    let LegalText: LegalTextBlock
    /// Save data.
    let SaveData: DataVersionBlock
}
