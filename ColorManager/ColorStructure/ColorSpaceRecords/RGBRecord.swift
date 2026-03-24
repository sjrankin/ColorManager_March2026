//
//  RGBRecord.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

struct RGBRecord: Identifiable, Equatable, ColorRecordToString, NativeColorConversion
{
    let id = UUID()
    let r: Int
    let g: Int
    let b: Int
    
    func AsString() -> String
    {
        return "\(r),\(g),\(b)"
    }
    
    func AsPercents() -> (Double, Double, Double)
    {
        return (Double(r) / 255.0, Double(g) / 255.0, Double(b) / 255.0)
    }
    
    func CreateNativeColor() -> PlatformColor?
    {
        let rx = Double(Double(r) / 255.0)
        let gx = Double(Double(g) / 255.0)
        let bx = Double(Double(b) / 255.0)
        return nil
    }
}
