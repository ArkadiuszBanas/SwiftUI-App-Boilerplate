//
//  BlurredImageView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct BlurredImageView: View {
    let image: UIImage
    let circles: [EditableCircle]
    let imageSize: CGSize
    @Binding var imageScale: CGFloat
    @Binding var imageOffset: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZoomableImageView(
                image: image,
                scale: $imageScale,
                offset: $imageOffset,
                onReset: {}
            )
            .blur(radius: 10)
            .mask(
                BlurMaskView(
                    circles: circles,
                    imageSize: imageSize,
                    imageScale: imageScale,
                    imageOffset: imageOffset,
                    containerSize: geometry.size
                )
            )
        }
    }
} 