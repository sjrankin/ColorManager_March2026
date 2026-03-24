//
//  DataVersionBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Versioning of the data.
struct DataVersionBlock: Equatable
{
    /// ID of the block.
    let id: UUID = UUID()
    /// Date of the version of the data. String format.
    let DataDate: String
    /// Version of the data.
    let Version: String
    /// ID of the data version.
    let DataID: UUID
}
