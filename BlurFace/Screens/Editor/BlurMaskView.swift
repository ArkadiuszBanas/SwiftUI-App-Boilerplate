//
//  BlurMaskView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct BlurMaskView: View {
    let circles: [EditableCircle]
    let imageSize: CGSize
    let imageScale: CGFloat
    let imageOffset: CGSize
    let containerSize: CGSize
    
    private func circleScreenPosition(for circle: EditableCircle) -> CGPoint {
        // Calculate the actual image size when scaled and fit to container
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        let actualImageSize: CGSize
        if imageAspect > containerAspect {
            // Image is constrained by width
            actualImageSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
        } else {
            // Image is constrained by height
            actualImageSize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
        }
        
        // Scale the image size by current scale
        let scaledImageSize = CGSize(
            width: actualImageSize.width * imageScale,
            height: actualImageSize.height * imageScale
        )
        
        // Calculate the image's top-left position in the container
        let imageTopLeft = CGPoint(
            x: (containerSize.width - scaledImageSize.width) / 2 + imageOffset.width,
            y: (containerSize.height - scaledImageSize.height) / 2 + imageOffset.height
        )
        
        // Convert normalized position to screen position
        return CGPoint(
            x: imageTopLeft.x + (circle.position.x * scaledImageSize.width),
            y: imageTopLeft.y + (circle.position.y * scaledImageSize.height)
        )
    }
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
            
            // Create circles for masking
            ForEach(circles) { circle in
                let screenPosition = circleScreenPosition(for: circle)
                let scaledWidth = circle.width * imageScale
                let scaledHeight = circle.height * imageScale
                
                Ellipse()
                    .fill(Color.white)
                    .frame(width: scaledWidth, height: scaledHeight)
                    .position(x: screenPosition.x, y: screenPosition.y)
            }
        }
    }
} 