//
//  AnalysisDetailView.swift
//  WordTagging
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI

struct AnalysisDetailView: View {
    let toolName: String
    var model: AITool
    @State private var userInput: String = ""
    @State private var result: String = "Enter text to analyze"

    var body: some View {
        VStack(spacing: 25) {
            Text(toolName)
                .font(.title2.bold())
                .foregroundColor(.blue)

            TextEditor(text: $userInput)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                .padding()

            Button("Analyze") {
                result = analyzeText(text: userInput, model: model)
            }
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)

            VStack {
                Text("Result:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(result)
                    .font(.title3)
                    .foregroundColor(result == "Positive" ? .green : .black)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline) // Keeps the top bar clean
    }

}
