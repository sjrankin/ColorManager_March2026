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

struct VersionBlock: Equatable
{
    let id: UUID = UUID()
    let FileVersion: FileVersionBlock
    let DataVersion: DataVersionBlock
    let LegalText: LegalTextBlock
    let SaveData: DataVersionBlock
}

struct FileVersionBlock: Equatable
{
    let id: UUID = UUID()
    let Date: String
    let Version: String
}

struct DataVersionBlock: Equatable
{
    let id: UUID = UUID()
    let DataDate: String
    let Version: String
    let DataID: UUID
}

struct LegalTextBlock: Equatable
{
    let id: UUID = UUID()
    let Copyright: String
    let Rights: String
}

struct SaveDataBlock: Equatable
{
    let id: UUID = UUID()
    let Written: String
}
