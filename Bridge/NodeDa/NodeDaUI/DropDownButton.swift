//
//  GlassyButton.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/13/24.
//

    import SwiftUI

        struct DropDownButtonStyle: ViewModifier {
            @Environment(\.colorScheme) private var colorScheme
            let isSelected: Bool
            let iconName: String
            
            func body(content: Content) -> some View {
                HStack {
                    content
                        .foregroundColor(isSelected ? (colorScheme == .dark ? .white : .black) : .gray)
                    Spacer()
                    Image(systemName: iconName)
                        .foregroundColor(.gray)
                }
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

        extension View {
            func glassyIngredientButton(isSelected: Bool, iconName: String) -> some View {
                self.modifier(DropDownButtonStyle(isSelected: isSelected, iconName: iconName))
            }
        }
