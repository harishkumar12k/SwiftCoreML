//
//  AnalysisDetailView.swift
//  SentimentalAnalysis
//
//  Created by Harish Kumar on 26/03/26.
//

import SwiftUI

struct AnalysisDetailView: View {
    let toolName: String
    @State private var userInput: String = ""
    @State private var sentimentResult: String = "Enter text to analyze"

    var body: some View {
        VStack(spacing: 25) {
            Text(toolName)
                .font(.title2.bold())
                .foregroundColor(.blue)

            TextEditor(text: $userInput)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .padding()

            Button("Analyze Sentiment") {
                sentimentResult = analyzeSentiment(text: userInput)
            }
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)

            VStack {
                Text("Result:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(sentimentResult)
                    .font(.title.bold())
                    .foregroundColor(sentimentResult == "Positive" ? .green : .black)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline) // Keeps the top bar clean
    }

}
