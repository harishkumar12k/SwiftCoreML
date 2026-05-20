//
//  ContentView.swift
//  HandPoseLive
//
//  Created by Harish Kumar on 15/05/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            CameraView(session: cameraManager.session)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text(cameraManager.prediction)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.7))
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

#Preview {
    ContentView()
}
