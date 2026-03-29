//
//  NativeToPlatformColor.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/29/26.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public extension NSColor
{
    /// Convenience variable to convert the instance `NSColor` to a `PlatformColor`.
    var ToPlatform: PlatformColor
    {
        return self
    }
    
    /// Convenience variable to convert the instance `NSColor` to a SwiftUI `Color`.
    var ToColor: Color
    {
        return Color(nsColor: self)
    }
}
#else
public extension UIColor
{
    /// Convenience variable to convert the instance `UIColor` to a `PlatformColor`.
    var ToPlatform: PlatformColor
    {
        return self
    }
    
    /// Convenience variable to convert the instance `UIColor` to a SwiftUI `Color`.
    var ToColor: Color
    {
        return Color(self)
    }
}
#endif
