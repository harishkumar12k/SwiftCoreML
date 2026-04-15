//
//  TagAnalyzer.swift
//  WordTagging
//
//  Created by Harish Kumar on 15/04/26.
//


import CoreML

func analyzeText(text: String, model: AITool) -> String {
    // 1. Initialize the model with a default configuration
    
    switch model {
    case .wordTaggerCRF:
        // Used https://www.kaggle.com/datasets/jp797498e/twitter-entity-sentiment-analysis
        guard let model = try? WordTaggerCRF(configuration: MLModelConfiguration()) else {
            return "Model loading failed"
        }
        guard let prediction = try? model.prediction(text: text) else {
            return "Prediction failed"
        }
        let labels = prediction.labels
        let tokens = prediction.tokens
        var tokenWithLabel: String = ""
        if labels.count == tokens.count {
            for (index, _) in labels.enumerated() {
                tokenWithLabel += "\(tokens[index])(\(labels[index]))\n"
            }
            return tokenWithLabel
        }
        return "\(prediction.tokens.joined(separator: " "))\n\(prediction.labels.joined(separator: " "))"
    }
    
}
