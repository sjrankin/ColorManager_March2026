//
//  LegalTextBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

/// Legal information.
struct LegalTextBlock: Equatable
{
    /// ID of the block.
    let id: UUID = UUID()
    /// Copyright string.
    let Copyright: String
    /// Rights string.
    let Rights: String
}
