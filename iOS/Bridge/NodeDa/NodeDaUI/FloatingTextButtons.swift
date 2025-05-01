//
//  FloatingTextButtons.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/18/24.
//
import SwiftUI

struct FloatingTextButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.primary)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        Color.white.opacity(0.2)
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FloatingTextButtons: View {
    var body: some View {
        HStack(spacing: 16) {
            FloatingTextButton(text: "Home") {
                print("Home tapped")
            }
            FloatingTextButton(text: "Search") {
                print("Search tapped")
            }
            FloatingTextButton(text: "Profile") {
                print("Profile tapped")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Color.white.opacity(0.2)
                VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
