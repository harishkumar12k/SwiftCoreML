//
//  SentimentAnalyzer.swift
//  SentimentalAnalysis
//
//  Created by Harish Kumar on 26/03/26.
//

import CoreML

func analyzeSentiment(text: String) -> String {
    // 1. Initialize the model with a default configuration
    // Used https://www.kaggle.com/datasets/jp797498e/twitter-entity-sentiment-analysis
    guard let model = try? TwitterSentimental(configuration: MLModelConfiguration()) else {
        return "Model loading failed"
    }
    
    // 2. Perform the prediction
    guard let prediction = try? model.prediction(text: text) else {
        return "Prediction failed"
    }
    
    // 3. Return the label (e.g., "Positive", "Negative", "Irrelevant" or "Neutral")
    return prediction.label
}
