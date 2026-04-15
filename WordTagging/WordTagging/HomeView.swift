//
//  HomeView.swift
//  WordTagging
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI

struct HomeView: View {

    let tools: [AITool] = [
        .wordTaggerCRF
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
    case wordTaggerCRF = "WordTaggerCRF"
    // Helper to return the correct model name for each tool
    var modelName: String {
        switch self {
        case .wordTaggerCRF: return "WordTaggerCRF"
        }
    }
}
