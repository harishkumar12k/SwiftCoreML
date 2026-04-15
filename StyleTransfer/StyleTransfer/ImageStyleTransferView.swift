//
//  ImageStyleTransferView.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI
import PhotosUI

struct ImageStyleTransferView: View {
    @StateObject private var viewModel = StyleTransferViewModel()
    
    // UI State
    @State private var selectedItem: PhotosPickerItem?
    @State private var inputImage: UIImage? = UIImage(named: "cartoon_3d_boy_trek")!
    @State private var showCamera = false
    let toolName: String
    var model: AITool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(toolName)
                .font(.title2.bold())
                .foregroundColor(.blue)
            // 1. Image Display
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 400)
                
                if let displayImage = viewModel.stylizedImage ?? inputImage {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    Text("Select a photo to begin")
                        .foregroundColor(.secondary)
                }
                
                if viewModel.isProcessing {
                    ProgressView("Stylizing...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            .padding()

            // 2. Action Buttons
            HStack(spacing: 20) {
                // Photo Library Picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Library", systemImage: "photo.on.rectangle")
                }
                .onChange(of: selectedItem) { _, newValue in
                    Task {
                        // Use newValue (the item just selected)
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.reset() // Reset old style result
                            inputImage = image.cropToSquare(size: 512)
                        }
                    }
                }

                // Camera Button
                Button {
                    showCamera = true
                    viewModel.reset()
                } label: {
                    Label("Camera", systemImage: "camera")
                }
            }
            .buttonStyle(.bordered)

            // 3. Process Button
            if let input = inputImage {
                Button("Apply ML Style") {
                    viewModel.applyStyle(to: input, model: model)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isProcessing)
            }
        }
        // Camera Sheet
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(image: $inputImage)
                .ignoresSafeArea()
        }
    }
}

extension UIImage {
    func cropToSquare(size: CGFloat = 512) -> UIImage? {
        // Fix rotation before doing anything else
        guard let normalizedImage = self.upOrientation(),
              let cgImage = normalizedImage.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let shortestSide = min(width, height)
        
        let xOffset = (width - shortestSide) / 2
        let yOffset = (height - shortestSide) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: shortestSide, height: shortestSide)
        
        guard let croppedCgImage = cgImage.cropping(to: cropRect) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { _ in
            // Use the normalized image's orientation (which is now .up)
            UIImage(cgImage: croppedCgImage).draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        }
    }
}

extension UIImage {
    func upOrientation() -> UIImage? {
        if imageOrientation == .up { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}

