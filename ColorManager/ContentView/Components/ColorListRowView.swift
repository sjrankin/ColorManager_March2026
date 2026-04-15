//
//  ColorListRowView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/15/26.
//

import Foundation
import SwiftUI

/// A single row in the color list view, showing a swatch, name, and hex value.
struct ColorListRowView: View
{
    let ColorRecord: ColorRecord
    let SwatchColor: Color
    let HexValue: String
    let IsSelected: Bool
    let OnTap: () -> Void

    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 10)
            {
                RoundedRectangle(cornerRadius: 4)
                    .fill(SwatchColor)
                    .frame(width: 36, height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.primary.opacity(0.15), lineWidth: 0.5))
                Text(ColorRecord.Name)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Text(HexValue)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(IsSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture
            {
                OnTap()
            }

            Divider()
                .padding(.leading, 54)
        }
    }
}
