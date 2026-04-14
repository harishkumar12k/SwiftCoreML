//
//  HomeView.swift
//  TextClassificationApp
//
//  Created by Harish Kumar on 26/03/26.
//

import SwiftUI

struct HomeView: View {

    let tools: [AITool] = [
        .twitterSentiment,
        .emotionalDetection,
        .spamHamClassifierMaxEntropy,
        .spamHamClassifierCondRanField,
        .spamHamClassifierTLStaticEmbedding,
        .spamHamClassifierELMoEmbedding,
        .spamHamClassifierBERTEmbedding
    ]
    
    var body: some View {
        NavigationStack {
            List(tools, id: \.self) { tool in
                NavigationLink(destination: AnalysisDetailView(toolName: tool.rawValue, model: tool)) {
                    Label(tool.rawValue, systemImage: "magnifyingglass.circle.fill")
                        .font(.headline)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("AI Tools")
        }
    }
}

#Preview {
    HomeView()
}

enum AITool: String, CaseIterable {
    case twitterSentiment = "TwitterSentimentalAnalysis"
    case emotionalDetection = "EmotionalDetection"
    case spamHamClassifierMaxEntropy = "SpamHamClassifierMaxEntropy"
    case spamHamClassifierCondRanField = "SpamHamClassifierCondRanField"
    case spamHamClassifierTLStaticEmbedding = "SpamHamClassifierTLStaticEmbedding"
    case spamHamClassifierELMoEmbedding = "SpamHamClassifierELMoEmbedding"
    case spamHamClassifierBERTEmbedding = "SpamHamClassifierBERTEmbedding"
    
    // Helper to return the correct model name for each tool
    var modelName: String {
        switch self {
        case .twitterSentiment: return "TwitterSentimental"
        case .emotionalDetection: return "EmotionalClassifier"
        case .spamHamClassifierMaxEntropy: return "SpamHamClassifierMaxEntropy"
        case .spamHamClassifierCondRanField: return "SpamHamClassifierCondRanField"
        case .spamHamClassifierTLStaticEmbedding: return "SpamHamClassifierTLStaticEmbedding"
        case .spamHamClassifierELMoEmbedding: return "SpamHamClassifierELMoEmbedding"
        case .spamHamClassifierBERTEmbedding: return "SpamHamClassifierBERTEmbedding"
        }
    }
}
