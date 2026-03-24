//
//  SaveDataBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Information about the last time the file was saved in XML format.
struct SaveDataBlock: Equatable
{
    /// ID of the data block.
    let id: UUID = UUID()
    /// Date (in string format) of the last save.
    let Written: String
}
