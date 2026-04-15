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

    var body: some View
    {
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
            NavigationSplitView
            {
                ColorSearchOptionView(Option: $SelectedOption)
            } detail: {
                switch(SelectedOption)
                {
                    case 0:
                        ColorNameSearchView()
                        
                    case 1:
                        ColorValueSearchView()
                        
                    case 2:
                        ColorCameraSearchView()
                        
                    default:
                        NoOptionView()
                }
            }
            Divider()
            HStack
            {
                Spacer()
                Button("Search")
                {

                }
                Spacer()
                Button("Cancel")
                {
                    self.Dismiss()
                }
                Spacer()
            }
            .padding()
        }
        .frame(height: 600)
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

struct ColorNameSearchView: View
{
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                Text("Color Name Search")
                Spacer()
            }
            Spacer()
        }
    }
}

struct ColorValueSearchView: View
{
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                Text("Color Value Search")
                Spacer()
            }
            Spacer()
        }
    }
}

struct ColorCameraSearchView: View
{
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                Text("Color Camera Search")
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
