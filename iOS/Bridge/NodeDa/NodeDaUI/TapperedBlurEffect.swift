//
//  TapperedBlurEffect.swift
//  Cookbook
//
//  Created by Anthony Silvia on 7/18/24.
//

import SwiftUI

struct TaperedBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: nil)
        let blur = UIBlurEffect(style: style)
        view.effect = blur
        
        // Create a gradient mask
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100) // Adjust height as needed
        gradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Apply the gradient mask to the blur view
        view.layer.mask = gradientMaskLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
