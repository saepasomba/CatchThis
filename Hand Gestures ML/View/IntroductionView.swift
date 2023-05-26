//
//  IntroductionView.swift
//  Hand Gestures ML
//
//  Created by Sae Pasomba on 25/05/23.
//

import SwiftUI

struct IntroductionView: View {
    
    @State var currentTab = 0
    
    var body: some View {
        TabView(selection: $currentTab) {
            VStack {
                Text("✋→✊")
                    .font(.largeTitle)
                
                Text("Hold Your Hand to Catch!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Position your hand so it is visible to the camera. This app uses camera and will process your hand gesture with machine learning.")
                    .font(.body)
                
                Button {
                    withAnimation {
                        currentTab = 1
                    }
                } label: {
                    Text("Next")
                }
                .buttonStyle(.borderedProminent)
            }
            .tag(0)
            .tabItem {
                Text("Intro 1")
            }
            
            VStack {
                Text("🔴→🟢")
                    .font(.largeTitle)
                
                Text("Hold Your Hand to Catch!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Position your hand so it is visible to the camera. This app uses camera and will process your hand gesture with machine learning.")
                    .font(.body)
                    .padding(.horizontal)
                
                NavigationLink {
                    MainView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("I Understand!")
                }
                .buttonStyle(.borderedProminent)
            }
            .tag(1)
            .tabItem {
                Text("Intro 2")
            }
        }
        .tabViewStyle(.page)
        .padding(.horizontal)
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
