//
//  StyleTransferViewModel.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI
import CoreML

class StyleTransferViewModel: ObservableObject {
    @Published var stylizedImage: UIImage?
    @Published var isProcessing = false

    func applyStyle(to inputImage: UIImage, model: AITool) {
        isProcessing = true
        switch model {
        case .imageSTSoftner:
            self.softner(inputImage: inputImage)
        case .liveSTSoftner:
            self.softner(inputImage: inputImage)
        }
    }
    
    func reset() {
        self.stylizedImage = nil
    }
    
    func softner(inputImage: UIImage) {
        // Move to background thread to prevent UI freezing
        DispatchQueue.global(qos: .userInitiated).async {
            let config = MLModelConfiguration()
            // 1. Load Model
            guard let model = try? FaceStyleTransfer_I300_SS1_SD512_Softner(configuration: config) else { return }
            
            // 2. Convert UIImage to CVPixelBuffer (Model usually expects 512x512)
            guard let pixelBuffer = inputImage.toPixelBuffer(width: 512, height: 512) else { return }
            
            do {
                // 3. Predict
                let output = try model.prediction(image: pixelBuffer)
                
                // 4. Convert back to UIImage
                let ciImage = CIImage(cvPixelBuffer: output.stylizedImage)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    let result = UIImage(cgImage: cgImage)
                    
                    DispatchQueue.main.async {
                        self.stylizedImage = result
                        self.isProcessing = false
                    }
                }
            } catch {
                print("ML Error: \(error)")
                DispatchQueue.main.async { self.isProcessing = false }
            }
        }
    }
}

extension UIImage {
    func toPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        
        guard let buffer = pixelBuffer, let ciImage = CIImage(image: self) else { return nil }
        
        // Calculate scale to FILL the 512x512 area (Aspect Fill)
        let scaleX = CGFloat(width) / ciImage.extent.width
        let scaleY = CGFloat(height) / ciImage.extent.height
        let scale = max(scaleX, scaleY) // 'max' ensures no black borders; 'min' would leave them
        
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // Center the image in the buffer
        let originX = (CGFloat(width) - scaledImage.extent.width) / 2
        let originY = (CGFloat(height) - scaledImage.extent.height) / 2
        let centeredImage = scaledImage.transformed(by: CGAffineTransform(translationX: originX, y: originY))
        
        CIContext().render(centeredImage, to: buffer)
        return buffer
    }
}

