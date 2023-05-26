//
//  MainView.swift
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
                VStack {
                    Spacer()
                    if mainViewModel.gameState == .playing {
                        Circle()
                            .fill(Color(mainViewModel.gameState == .playing && mainViewModel.currentTimer < mainViewModel.secondsToGreen ? .red : .green))
                            .frame(width: 100, height: 100)
                            .padding(.bottom)
                    } else if mainViewModel.gameState == .finished {
                        VStack(spacing: 16) {
                            VStack {
                                Text("Your reaction time:")
                                Text("\(mainViewModel.gameResult?.time ?? 0, specifier: "%.3f")")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(8)
                            
                            VStack {
                                Text("\(mainViewModel.gameResult?.responseClass ?? "Kecepatan Cahaya")")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(width: 275)
                                
                                Text("\(mainViewModel.gameResult?.description ?? "Lorem Ipsum eaeaeaeae eaeaea aeae aeaea aeae")")
                                    .multilineTextAlignment(.center)
                                    .frame(width: 275)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(8)
                        }

                        .padding(.bottom)
                    }
                }
            }
            .shadow(radius: 10)
            .frame(width: 355, height: 600)
            .cornerRadius(10)
            .padding(.vertical)
            
            
            if mainViewModel.gameState == .prePlay || mainViewModel.gameState == .finished {
                VStack {
                    Text("Make sure your hand is visible when starting!")
                        .font(.caption)
                    Button {
                        mainViewModel.startGaming()
                    } label: {
                        Text(mainViewModel.gameState == .prePlay ? "Tap to play!" : "Play again!")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            
        }
        .onReceive(mainViewModel.timer) { time in
            mainViewModel.handleTimer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
