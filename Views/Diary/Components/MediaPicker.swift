import SwiftUI
import PhotosUI

struct MediaPicker: View {
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var selectedImages: [Image]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("diary.media.title", comment: ""))
                    .font(.headline)
                
                Spacer()
                
                PhotosPicker(selection: $selectedItems,
                           matching: .images,
                           photoLibrary: .shared()) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }
            
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            selectedImages[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    Button(action: {
                                        withAnimation {
                                            selectedImages.remove(at: index)
                                            selectedItems.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .padding(4),
                                    alignment: .topTrailing
                                )
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text(NSLocalizedString("diary.media.empty", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .onChange(of: selectedItems) { oldValue, newValue in
            Task {
                selectedImages.removeAll()
                
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(Image(uiImage: uiImage))
                    }
                }
            }
        }
    }
} 