//
//  SoundClassifierView.swift
//  SoundClassification
//
//  Created by Harish Kumar on 16/04/26.
//

import SwiftUI

struct SoundClassifierView: View {
    @StateObject private var viewModel = SoundClassifierViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sound Classifier")
                .font(.largeTitle)
                .bold()
            
            VStack {
                Text(viewModel.detectedSound.capitalized)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text(String(format: "Confidence: %.2f%%", viewModel.confidence * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(40)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            
            Button(action: {
                viewModel.toggleClassification()
            }) {
                Label(
                    title: { Text(viewModel.isRecording ? "Stop Listening" : "Start Listening") },
                    icon: { Image(systemName: viewModel.isRecording ? "stop.fill" : "play.fill") }
                )
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
