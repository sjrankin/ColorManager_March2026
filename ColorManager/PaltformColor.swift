import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if canImport(UIKit)
    typealias PlatformColor = UIColor
#elseif canImport(AppKit)
    typealias PlatformColor = NSColor
#endif

