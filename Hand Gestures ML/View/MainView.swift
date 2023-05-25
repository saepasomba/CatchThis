//
//  ContentView.swift
//  Hand Gestures ML
//
//  Created by Sae Pasomba on 19/05/23.
//

import SwiftUI
import Vision

struct MainView: View {
    @ObservedObject var mainViewModel = MainViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .opacity(0.2)
                CameraView()
                    .onFrameCaptured { frame in
                        mainViewModel.handleFrame(frame)
                    }
            }
            .shadow(radius: 10)
                .frame(width: 350, height: 550)
                .cornerRadius(10)
                .padding(.vertical)
            
            Text("\(mainViewModel.predictionLabel ?? "Make sure your hand is visible!")")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
