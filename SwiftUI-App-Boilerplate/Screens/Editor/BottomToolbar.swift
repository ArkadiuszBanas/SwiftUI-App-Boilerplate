import SwiftUI
import PhotosUI

struct BottomToolbar: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    let selectedImage: UIImage?
    let onAddShape: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Load Photo
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                    Text("Load Photo")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .accessibilityLabel("Load Photo")
            .accessibilityHint("Opens photo gallery to select an image")
            
            // Add Shape
            Button {
                onAddShape()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "drop")
                        .font(.system(size: 24))
                    Text("Add Blur")
                        .font(.caption)
                }
                .foregroundColor(selectedImage == nil ? .gray : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .disabled(selectedImage == nil)
            .accessibilityLabel("Add Blur")
            .accessibilityHint("Adds a movable ellipse to blur areas of the image")
            
            // Export
            Button {
                onExport()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24))
                    Text("Export")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .disabled(selectedImage == nil)
            .accessibilityLabel("Export Image")
            .accessibilityHint("Saves the edited image to your photo library")
        }
        .background(
            Rectangle()
                .fill(.ultraThickMaterial)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    BottomToolbar(
        selectedPhoto: .constant(nil),
        selectedImage: nil,
        onAddShape: {},
        onExport: {}
    )
} 