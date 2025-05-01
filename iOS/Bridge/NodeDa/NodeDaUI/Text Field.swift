//
//  Text Field.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/14/24.
//
    import SwiftUI

    struct GlassyTextFieldStyle: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            
            func body(content: Content) -> some View {
                content
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.8))
                    .background(backgroundView)
            }
            
            private var backgroundView: some View {
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            }
        }

        extension View {
            func glassyTextFieldStyle() -> some View {
                self.modifier(GlassyTextFieldStyle())
            }
        }
