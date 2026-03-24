//
//  VersionBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct VersionBlock: Equatable
{
    let id: UUID = UUID()
    let FileVersion: FileVersionBlock
    let DataVersion: DataVersionBlock
    let LegalText: LegalTextBlock
    let SaveData: DataVersionBlock
}
