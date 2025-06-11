//
//  EditorView.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import PhotosUI

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    
    init(viewModel: EditorViewModel = EditorViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Image Display Area
            if let selectedImage = viewModel.selectedImage {
                ZoomableImageView(
                    image: selectedImage,
                    scale: $viewModel.imageScale,
                    offset: $viewModel.imageOffset,
                    onReset: viewModel.resetZoom
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            } else {
                // Placeholder when no image is selected
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No image selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap 'Load Photo' to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Toolbar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Load Photo
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                            Text("Load Photo")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .accessibilityLabel("Load Photo")
                    .accessibilityHint("Opens photo gallery to select an image")
                    
                    // Auto Detect Faces
                    Button {
                        Task {
                            await viewModel.detectFaces()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Image(systemName: "face.dashed")
                                    .font(.system(size: 24))
                                
                                if viewModel.isDetectingFaces {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            Text("Detect Faces")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil || viewModel.isDetectingFaces)
                    .accessibilityLabel("Auto Detect Faces")
                    .accessibilityHint("Automatically detects faces in the selected image")
                    
                    // Add Shape
                    Button {
                        viewModel.addShape()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: viewModel.isAddingShape ? "rectangle.badge.checkmark" : "rectangle.badge.plus")
                                .font(.system(size: 24))
                            Text("Add Shape")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : (viewModel.isAddingShape ? .blue : .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil)
                    .accessibilityLabel("Add Shape")
                    .accessibilityHint("Adds shapes to blur or highlight areas of the image")
                    
                    // Export
                    Button {
                        viewModel.exportImage()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text("Export")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.selectedImage == nil ? .gray : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.selectedImage == nil)
                    .accessibilityLabel("Export Image")
                    .accessibilityHint("Saves the edited image to your photo library")
                }
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task {
                await viewModel.loadImage()
            }
        }
    }
}

#Preview {
    EditorView()
} 