//
//  Menu.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/14/24.
//

    import SwiftUI

        struct GlassyMenuStyle: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            let isSelected: Bool?
            
            func body(content: Content) -> some View {
                content
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            }
        }

        struct GlassyMenuLabelStyle: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            let isSelected: Bool?
            
            func body(content: Content) -> some View {
                HStack {
                    content
                        .foregroundColor(isSelected == true ? (colorScheme == .dark ? .white : .black) : .gray)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
            }
        }

        extension View {
            func glassyMenuStyle(isSelected: Bool? = nil) -> some View {
                self.modifier(GlassyMenuStyle(isSelected: isSelected))
            }
            
            func glassyMenuLabelStyle(isSelected: Bool? = nil) -> some View {
                self.modifier(GlassyMenuLabelStyle(isSelected: isSelected))
            }
        }
