//
//  LiveStyleViewModel.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import AVFoundation
import Vision
import UIKit

class LiveStyleViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var stylizedFrame: UIImage?
    private let captureSession = AVCaptureSession()
    private var model: VNCoreMLModel?
    
    private let sessionQueue = DispatchQueue(label: "com.app.sessionQueue")

    override init() {
        super.init()
        setupModel()
        
        // Move session configuration and startRunning to the background
        sessionQueue.async {
            self.setupCamera()
            self.captureSession.startRunning()
        }
    }

    func setupModel() {
        // Use Vision for automatic resizing and performance
        if let coreMLModel = try? FaceStyleTransfer_I300_SS1_SD512_VideoSoftner(configuration: MLModelConfiguration()).model {
            self.model = try? VNCoreMLModel(for: coreMLModel)
        }
    }

    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else { return }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(output) {
            captureSession.addInput(input)
            captureSession.addOutput(output)
        }
        // Find the connection between the camera and the video output
        if let connection = captureSession.connections.first(where: { $0.output is AVCaptureVideoDataOutput }) {
            if connection.isVideoRotationAngleSupported(90) {
                // 90 degrees = Portrait
                connection.videoRotationAngle = 90
            }
        }
        captureSession.commitConfiguration()
    }

    // This delegate runs for EVERY frame from the camera
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let model = model else { return }

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let result = request.results?.first as? VNPixelBufferObservation {
                let ciImage = CIImage(cvPixelBuffer: result.pixelBuffer)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    DispatchQueue.main.async {
                        self.stylizedFrame = UIImage(cgImage: cgImage)
                    }
                }
            }
        }
        
        // Ensure the camera frame is cropped/scaled correctly to fit the model
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
