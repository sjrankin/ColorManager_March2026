//
//  FileVersionBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Version information of the file holding the colors.
struct FileVersionBlock: Equatable
{
    /// ID of the block.
    let id: UUID = UUID()
    /// Date of the format of the file.
    let Date: String
    /// Version of the format of the file.
    let Version: String
}
