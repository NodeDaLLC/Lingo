//
//  FloatingNavButtons.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/8/24.
//
import SwiftUI

struct FloatingButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .font(.system(size: 16))
                .frame(width: 40, height: 40)
                .background(
                    ZStack {
                        Color.white.opacity(0.2)
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
                    }
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FloatingNavButtons: View {
    var body: some View {
        HStack(spacing: 16) {
            FloatingButton(icon: "house") {
                print("Home tapped")
            }
            FloatingButton(icon: "magnifyingglass") {
                print("Search tapped")
            }
            FloatingButton(icon: "person") {
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

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
