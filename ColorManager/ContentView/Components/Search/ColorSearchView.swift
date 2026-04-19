//
//  ColorSearchView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/15/26.
//

import Foundation

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ColorSearchView: View
{
    @Environment(\.dismiss) var Dismiss
    @State var SelectedOption: Int = 0
    @State var SearchMethod: SearchRecord? = nil

    var body: some View
    {
#if os(macOS)
        VStack(spacing: 0)
        {
            HStack
            {
                Spacer()
                Text("Color Searcher")
                    .font(.title)
                Spacer()
            }
            .padding()
            Divider()
            HStack(spacing: 0)
            {
                ColorSearchOptionView(Option: $SelectedOption)
                    .frame(width: 140)
                    .background(Color.secondary.opacity(0.08))
                Divider()
                Group
                {
                    switch SelectedOption
                    {
                        case 0: ColorNameSearchView(Searcher: $SearchMethod)
                        case 1: ColorValueSearchView(Searcher: $SearchMethod)
                        case 2: ColorCameraSearchView(Searcher: $SearchMethod)
                        default: NoOptionView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            Divider()
            HStack
            {
                Spacer()
                Button("Search") {}
                Spacer()
                Button("Cancel") { self.Dismiss() }
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#else
        VStack(spacing: 0)
        {
            // Title
            Text("Color Searcher")
                .font(.title2.bold())
                .padding(.top, 16)
                .padding(.bottom, 8)

            Divider()

            // Option picker replaces sidebar on compact screens
            Picker("", selection: $SelectedOption)
            {
                Text("Name").tag(0)
                Text("Color").tag(1)
                Text("Camera").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Detail content
            Group
            {
                switch SelectedOption
                {
                    case 0: ColorNameSearchView(Searcher: $SearchMethod)
                    case 1: ColorValueSearchView(Searcher: $SearchMethod)
                    case 2: ColorCameraSearchView(Searcher: $SearchMethod)
                    default: NoOptionView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            HStack
            {
                Spacer()
                Button("Search") {}
                Spacer()
                Button("Cancel") { self.Dismiss() }
                Spacer()
            }
            .padding(.vertical, 12)
        }
#endif
    }
}

struct NoOptionView: View
{
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                Text("No search option set")
                Spacer()
            }
            Spacer()
        }
    }
}

struct ColorSearchOptionView: View
{
    @Binding var Option: Int

    private let options: [(label: String, value: Int)] =
    [
        ("Name",  0),
        ("Color", 1),
        ("Camera", 2)
    ]

    var body: some View
    {
        VStack(spacing: 0)
        {
            ForEach(options, id: \.value)
            { option in
                HStack
                {
                    Text(option.label)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Option == option.value ? Color.accentColor.opacity(0.12) : Color.clear)
                .contentShape(Rectangle())
                .onTapGesture
                {
                    Option = option.value
                }
                Divider()
            }
            Spacer()
        }
    }
}
