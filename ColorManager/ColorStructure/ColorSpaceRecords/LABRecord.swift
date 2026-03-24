//
//  LABRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct LABRecord: Identifiable, Equatable, ColorRecordToString
{
    let id = UUID()
    let l: Double
    let a: Double
    let b: Double
    
    func AsString() -> String
    {
        return "\(l),\(a),\(b)"
    }
}
