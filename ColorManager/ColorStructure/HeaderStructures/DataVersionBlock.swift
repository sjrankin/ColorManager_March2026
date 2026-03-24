//
//  DataVersionBlock.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct DataVersionBlock: Equatable
{
    let id: UUID = UUID()
    let DataDate: String
    let Version: String
    let DataID: UUID
}
