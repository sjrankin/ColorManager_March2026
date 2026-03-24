//
//  HSBRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct HSBRecord: Identifiable, Equatable, ColorRecordToString
{
    let id = UUID()
    let h: Double
    let s: Double
    let b: Double
    
    func AsString() -> String
    {
        return "\(h),\(s),\(b)"
    }
}
