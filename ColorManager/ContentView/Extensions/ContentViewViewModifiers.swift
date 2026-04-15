//
//  ContentViewViewModifiers.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/13/26.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - View Modifiers

extension View
{
    /// Apply toolbar button styling based on platform
    @ViewBuilder func toolbarButtonStyle(prominent: Bool = true) -> some View
    {
#if os(macOS)
        self
            .buttonStyle(.bordered)
            .controlSize(.large)
#else
        if prominent
        {
            self.buttonStyle(.borderedProminent)
        }
        else
        {
            self.buttonStyle(.bordered)
        }
#endif
    }
}
