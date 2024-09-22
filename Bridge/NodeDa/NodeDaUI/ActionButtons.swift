//
//  ActionButtons.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/13/24.
//

    //MARK: Action Buttons
        /*struct ActionButton: View {
            let action: () -> Void
            let label: String
            let icon: String
            let backgroundColor: Color  // This controls the text and icon color
            @Environment(\.colorScheme) private var colorScheme

            init(label: String, icon: String, backgroundColor: Color, action: @escaping () -> Void) {
                self.label = label
                self.icon = icon
                self.backgroundColor = backgroundColor
                self.action = action
            }

            private var glassBackground: some View {
                ZStack {
                    Color.clear
                    
                    if colorScheme == .dark {
                        Color.white.opacity(0.1)
                    } else {
                        Color.white.opacity(0.7)
                    }
                }
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }

            private var glassHighlight: some View {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.3 : 0.5),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(1)
            }

            public var body: some View {
                Button(action: action) {
                    Label(label, systemImage: icon)
                        .foregroundColor(backgroundColor)  // Use backgroundColor for text and icon
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(glassBackground)
                        .overlay(glassHighlight)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        */
