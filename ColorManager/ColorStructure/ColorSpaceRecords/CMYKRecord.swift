//
//  CMYKRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct CMYKRecord: Identifiable, Equatable, ColorRecordToString
{
    let id = UUID()
    let c: Double
    let y: Double
    let m: Double
    let k: Double
    
    func AsString() -> String
    {
        return "\(c),\(m),\(y),\(k)"
    }
}
