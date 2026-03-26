//
//  SentimentAnalyzer.swift
//  TextClassificationApp
//
//  Created by Harish Kumar on 26/03/26.
//

import CoreML

func analyzeText(text: String, model: AITool) -> String {
    // 1. Initialize the model with a default configuration
    
    switch model {
    case .twitterSentiment:
        // Used https://www.kaggle.com/datasets/jp797498e/twitter-entity-sentiment-analysis
        guard let model = try? TwitterSentimental(configuration: MLModelConfiguration()) else {
            return "Model loading failed"
        }
        guard let prediction = try? model.prediction(text: text) else {
            return "Prediction failed"
        }
        return prediction.label
    case .emotionalDetection:
        // Used https://www.kaggle.com/datasets/prajwalnayakat/text-emotion
        guard let model = try? EmotionalClassifier(configuration: MLModelConfiguration()) else {
            return "Model loading failed"
        }
        guard let prediction = try? model.prediction(text: text) else {
            return "Prediction failed"
        }
        return prediction.label
    }
    
}
