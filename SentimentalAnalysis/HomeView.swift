//
//  HomeView.swift
//  SentimentalAnalysis
//
//  Created by Harish Kumar on 26/03/26.
//

import SwiftUI

struct HomeView: View {

    let tools = ["TwitterSentimentalAnalysis"]
    
    var body: some View {
        NavigationStack {
            List(tools, id: \.self) { tool in
                NavigationLink(destination: AnalysisDetailView(toolName: tool)) {
                    Label(tool, systemImage: "magnifyingglass.circle.fill")
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
