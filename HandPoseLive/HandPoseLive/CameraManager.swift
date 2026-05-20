//
//  CameraManager.swift
//  HandPoseLive
//
//  Created by Harish Kumar on 15/05/26.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import SwiftUI

class CameraManager: NSObject, ObservableObject {

    @Published var prediction: String = "Detecting..."

    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private lazy var model: HandPoseClassifier = {
        let config = MLModelConfiguration()
        return try! HandPoseClassifier(configuration: config)
    }()

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        videoOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "VideoQueue")
        )
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        session.commitConfiguration()
    }

    func startSession() {
        guard !session.isRunning else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        guard session.isRunning else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }

    private func processObservation(_ observation: VNHumanHandPoseObservation) {
        do {
            let points = try observation.recognizedPoints(.all)
            let multiArray = try MLMultiArray(shape: [1, 3, 21], dataType: .double)
            let jointNames: [VNHumanHandPoseObservation.JointName] = [
                .wrist,

                .thumbCMC,
                .thumbMP,
                .thumbIP,
                .thumbTip,

                .indexMCP,
                .indexPIP,
                .indexDIP,
                .indexTip,

                .middleMCP,
                .middlePIP,
                .middleDIP,
                .middleTip,

                .ringMCP,
                .ringPIP,
                .ringDIP,
                .ringTip,

                .littleMCP,
                .littlePIP,
                .littleDIP,
                .littleTip
            ]

            for (index, joint) in jointNames.enumerated() {
                guard let point = points[joint] else {
                    continue
                }
                multiArray[[0, 0, NSNumber(value: index)]] =
                    NSNumber(value: point.x)
                multiArray[[0, 1, NSNumber(value: index)]] =
                    NSNumber(value: point.y)
                multiArray[[0, 2, NSNumber(value: index)]] =
                    NSNumber(value: point.confidence)
            }
            let input = HandPoseClassifierInput(
                poses: multiArray
            )
            let result = try model.prediction(input: input)
            DispatchQueue.main.async {
                self.prediction = result.label
            }
        } catch {
            print("Prediction Error:", error)
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            processObservation(observation)
        } catch {
            print("Vision Error:", error)
        }
    }
    
}
