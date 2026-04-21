//
//  HomeView.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI

struct HomeView: View {

    let tools: [AITool] = [
        .imageSTSoftner,
        .liveSTSoftner,
        .imageSTSharpner
    ]
    
    var body: some View {
        NavigationStack {
            List(tools, id: \.self) { tool in
                if tool == .liveSTSoftner {
                    NavigationLink(destination: LiveStyleTransferView()) {
                        Label(tool.rawValue, systemImage: "magnifyingglass.circle.fill")
                            .font(.headline)
                            .padding(.vertical, 8)
                    }
                } else {
                    NavigationLink(destination: ImageStyleTransferView(toolName: tool.rawValue, model: tool)) {
                        Label(tool.rawValue, systemImage: "magnifyingglass.circle.fill")
                            .font(.headline)
                            .padding(.vertical, 8)
                    }
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
    case imageSTSharpner = "Image Sharpner"
    case liveSTSoftner = "Live Video Softner"
    // Helper to return the correct model name for each tool
    var modelName: String {
        switch self {
        case .imageSTSoftner: return "FaceStyleTransfer_I300_SS1_SD512_Softner"
        case .liveSTSoftner: return "FaceStyleTransfer_I300_SS1_SD512_VideoSoftner"
        case .imageSTSharpner: return "SharpeningStyleTransfer_I1000_SS5_SD256"
        }
    }
}
