//
//  StyleTransferViewModel.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI
import CoreML
import CoreImage
import Vision

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
        case .imageSTSharpner:
            self.sharpner(inputImage: inputImage)
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
    
    func sharpner(inputImage: UIImage) {
        // 0. Keep a reference to the original CIImage and its orientation
        guard let originalCI = CIImage(image: inputImage) else { return }
        let originalOrientation = inputImage.imageOrientation
        
        DispatchQueue.global(qos: .userInitiated).async {
            let config = MLModelConfiguration()
            guard let model = try? FaceStyleTransfer_I300_SS1_SD512_Softner(configuration: config) else { return }
            
            // 1. ISOLATE LUMINANCE: Convert to Grayscale BEFORE sending to ML
            // This prevents the model from ever seeing (or changing) the colors.
            let monoCI = originalCI.applyingFilter("CIPhotoEffectMono")
            
            // Convert the grayscale CIImage to UIImage for existing toPixelBuffer helper
            let context = CIContext() // Ideally, use a persistent context property
            guard let monoCG = context.createCGImage(monoCI, from: monoCI.extent) else { return }
            let monoUIImage = UIImage(cgImage: monoCG)

            // 2. Predict on the Mono image
            guard let pixelBuffer = monoUIImage.toPixelBuffer(width: 512, height: 512) else { return }
            
            do {
                let output = try model.prediction(image: pixelBuffer)
                
                // 3. THE RECOVERY: Merge Sharpened Luma back with Original Color
                let sharpenedLuma = CIImage(cvPixelBuffer: output.stylizedImage)
                
                // Resize sharpenedLuma back to original size to match originalCI
                let scaleX = originalCI.extent.width / sharpenedLuma.extent.width
                let scaleY = originalCI.extent.height / sharpenedLuma.extent.height
                let resizedLuma = sharpenedLuma.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                // BLEND: Take sharpness from 'resizedLuma' and colors from 'originalCI'
                let finalCI = resizedLuma.applyingFilter("CILuminosityBlendMode", parameters: [
                    kCIInputBackgroundImageKey: originalCI
                ])
                
                // 4. Render and preserve orientation
                if let finalCG = context.createCGImage(finalCI, from: originalCI.extent) {
                    let result = UIImage(cgImage: finalCG, scale: inputImage.scale, orientation: originalOrientation)
                    
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

