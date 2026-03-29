import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if canImport(UIKit)
    public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
    public typealias PlatformColor = NSColor
#endif

