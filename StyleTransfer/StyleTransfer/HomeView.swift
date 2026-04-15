//
//  HomeView.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI

struct HomeView: View {

    let tools: [AITool] = [
        .imageSTSoftner
    ]
    
    var body: some View {
        NavigationStack {
            List(tools, id: \.self) { tool in
                NavigationLink(destination: ImageStyleTransferView(toolName: tool.rawValue, model: tool)) {
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
    case imageSTSoftner = "Image Softner"
    // Helper to return the correct model name for each tool
    var modelName: String {
        switch self {
        case .imageSTSoftner: return "FaceStyleTransfer_I300_SS1_SD512_Softner"
        }
    }
}
