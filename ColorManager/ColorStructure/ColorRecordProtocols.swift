//
//  ColorRecordProtocols.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation

protocol ColorRecordToString
{
    func AsString() -> String
}

protocol NativeColorConversion
{
    func CreateNativeColor() -> PlatformColor?
}
