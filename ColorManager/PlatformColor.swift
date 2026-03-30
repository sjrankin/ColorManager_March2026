//
//  PlatformColor.swift
//  ColorManager
//
//  Created by Stuart Rankin on 3/29/26.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias PlatformColor = NSColor
#else
public typealias PlatformColor = UIColor
#endif
