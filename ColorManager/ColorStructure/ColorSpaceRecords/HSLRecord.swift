//
//  HSLRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct HSLRecord: Identifiable, Equatable, ColorRecordToString
{
    let id = UUID()
    let h: Double
    let s: Double
    let l: Double
    
    func AsString() -> String
    {
        return "\(h),\(s),\(l)"
    }
}
