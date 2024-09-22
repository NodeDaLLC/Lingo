//
//  Button2.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/13/24.
//
    import SwiftUI

        enum CustomButtonStyle {
            case glassy
            case ghost
            case secondary
        }

        struct CustomizableButtonStyle: ButtonStyle {
            @Environment(\.colorScheme) private var colorScheme
            var style: CustomButtonStyle
            var labelColor: Color
            var backgroundColor: Color?
            
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .font(.system(size: 16))
                    .foregroundColor(labelColor)
                    .background(
                        Group {
                            switch style {
                            case .glassy:
                                glassyBackground
                            case .ghost:
                                Color.clear // No background for ghost style
                            case .secondary:
                                secondaryBackground
                            }
                        }
                    )
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            }
            
            @ViewBuilder
            private var glassyBackground: some View {
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
            }
            
            @ViewBuilder
            private var secondaryBackground: some View {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor ?? labelColor.opacity(0.08))
            }
        }
