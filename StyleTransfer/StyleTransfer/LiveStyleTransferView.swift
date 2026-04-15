//
//  LiveStyleTransferView.swift
//  StyleTransfer
//
//  Created by Harish Kumar on 15/04/26.
//

import SwiftUI

struct LiveStyleTransferView: View {
    @StateObject private var viewModel = LiveStyleViewModel()

    var body: some View {
        ZStack {
            if let frame = viewModel.stylizedFrame {
                Image(uiImage: frame)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                ProgressView("Starting Camera...")
            }
        }
    }
}
