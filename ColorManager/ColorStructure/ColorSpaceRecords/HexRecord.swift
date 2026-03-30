//
//  HexRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct HexRecord: Identifiable, Equatable, ColorRecordToString
{
    let id = UUID()
    let HexValue: String
    
    func AsString() -> String
    {
        return HexValue
    }
    
    func AsString(Prefix: String) -> String
    {
        return "\(Prefix)\(AsString())"
    }
    
    var Channels: (red: Int, green: Int, blue: Int)
    {
        Convert.FromHexToChannels(self.HexValue)
    }
}
