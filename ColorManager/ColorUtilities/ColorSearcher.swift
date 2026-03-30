//
//  ColorSearcher.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/30/26.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class ColorSearcher
{
    static func Distance(from: ColorRecord, to: ColorRecord) -> Double
    {
        guard let FromColor = from.Hex?.Channels,
              let ToColor = to.Hex?.Channels else
        {
            return Double.greatestFiniteMagnitude
        }
        
        let RedDiff = Double(FromColor.red - ToColor.red)
        let GreenDiff = Double(FromColor.green - ToColor.green)
        let BlueDiff = Double(FromColor.blue - ToColor.blue)
        
        let RedSquared = pow(RedDiff, 2.0)
        let GreenSquared = pow(GreenDiff, 2.0)
        let BlueSquared = pow(BlueDiff, 2.0)
        
        let sum = RedSquared + GreenSquared + BlueSquared
        let distance = sqrt(sum)
        
        return distance
    }
}
