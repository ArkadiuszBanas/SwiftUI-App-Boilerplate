//
//  EmptyStateView.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(NSLocalizedString("editor.no_image_selected", comment: ""))
                .font(.headline)
                .foregroundColor(.secondary)
            Text(NSLocalizedString("editor.load_photo_instruction", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 