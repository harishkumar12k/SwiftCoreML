//
//  HomeView.swift
//  SoundClassification
//
//  Created by Harish Kumar on 16/04/26.
//

import SwiftUI

struct HomeView: View {

    let tools: [AITool] = [
        .soundClassifierVGGish
    ]
    
    var body: some View {
        NavigationStack {
            List(tools, id: \.self) { tool in
                NavigationLink(destination: SoundClassifierView()) {
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
    case soundClassifierVGGish = "SoundClassifierVGGish"
    // Helper to return the correct model name for each tool
    var modelName: String {
        switch self {
        case .soundClassifierVGGish: return "SoundClassifierVGGish"
        }
    }
}
