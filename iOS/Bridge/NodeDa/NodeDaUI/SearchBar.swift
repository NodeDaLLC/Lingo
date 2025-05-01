//
//  SearchBar.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/8/24.
//

import SwiftUI

struct GlassySearchBarStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            configuration
                .padding(.vertical, 12)
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        )
        //.shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension TextFieldStyle where Self == GlassySearchBarStyle {
    static var glassy: GlassySearchBarStyle { GlassySearchBarStyle() }
}
