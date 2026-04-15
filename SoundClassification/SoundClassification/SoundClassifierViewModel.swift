//
//  SoundClassifierViewModel.swift
//  SoundClassification
//
//  Created by Harish Kumar on 16/04/26.
//

import SwiftUI
import SoundAnalysis
import AVFoundation

class SoundClassifierViewModel: NSObject, ObservableObject, SNResultsObserving {
    @Published var detectedSound: String = "Waiting..."
    @Published var confidence: Double = 0.0
    @Published var isRecording: Bool = false // Tracks the state
    
    private let engine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private let queue = DispatchQueue(label: "com.soundanalysis.queue")
    
    func toggleClassification() {
        if isRecording {
            stopClassification()
        } else {
            startLiveClassification()
        }
    }
    
    private func startLiveClassification() {
        do {
            let inputNode = engine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            streamAnalyzer = SNAudioStreamAnalyzer(format: format)
            
            let config = MLModelConfiguration()
            let model = try SoundClassifierVGGish(configuration: config).model
            let request = try SNClassifySoundRequest(mlModel: model)
            
            try streamAnalyzer?.add(request, withObserver: self)
            
            inputNode.installTap(onBus: 0, bufferSize: 8192, format: format) { buffer, time in
                self.queue.async {
                    self.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
            
            try engine.start()
            isRecording = true
        } catch {
            print("Start error: \(error)")
        }
    }
    
    private func stopClassification() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0) // Important: prevents memory leaks/crashes
        streamAnalyzer = nil
        isRecording = false
        detectedSound = "Stopped"
        confidence = 0.0
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }
        
        DispatchQueue.main.async {
            self.detectedSound = top.identifier
            self.confidence = top.confidence
        }
    }
}
