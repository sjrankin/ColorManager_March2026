//
//  CMColor.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/24/26.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Visual representation of a color from the color list.
/// - Note: Colors are returned in their native OS formats, not SwiftUI's `Color`.
class CMColor
{
    #if os(macOS)
    public private(set) var Native: NSColor = .white
    #else
    public private(set) var Native: UIColor = .white
    #endif
}
