//
//  LongFormText.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/13/24.
//

import SwiftUI

struct GlassyTextEditorStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
            .font(.system(size: 16))
            .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.8))
    }
}

struct ResizableGlassyTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    @State private var textEditorHeight: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.clear)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $text)
                .frame(height: max(100, textEditorHeight))
                .modifier(GlassyTextEditorStyle())
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    func glassyTextEditor() -> some View {
        self.modifier(GlassyTextEditorStyle())
    }
}
