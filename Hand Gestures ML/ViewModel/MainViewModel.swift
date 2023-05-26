//
//  MainViewModel.swift
//  Hand Gestures ML
//
//  Created by Sae Pasomba on 25/05/23.
//

import Foundation
import Vision
import UIKit


// MARK: Game State Enum
enum GameState {
    case prePlay
    case playing
    case finished
}

struct GameResult {
    let isRight: Bool
    let responseClass: String
    let description: String
    let time: Double
}


// MARK: Camera Frame Handling
class MainViewModel: ObservableObject {
    @Published var predictionLabel: String?
    @Published var gameState: GameState = .prePlay
    
    @Published var currentTimer: Double = 0
    @Published var secondsToGreen: Double = 0
    
    @Published var gameResult: GameResult?
    
    var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    func handleFrame(_ frame: UIImage) {
        
        guard let ciImage = frame.ciImage else {
            print("Not converted")
            return
        }
        
        let requestHandler = VNImageRequestHandler(ciImage: ciImage)
        
        let request = VNDetectHumanHandPoseRequest(completionHandler: handPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform request: \(error.localizedDescription)")
        }
    }
    
    func handPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanHandPoseObservation] else {
            print("Observations failed")
            return
        }
        if !observations.isEmpty {
            processObservation(observations[0])
            
        }
    }
    
    func processObservation(_ observation: VNHumanHandPoseObservation) {
        
        guard let mlMultiArray = try? observation.keypointsMultiArray() else {
            return
        }
        
        guard let modelClassifier = try? HandPoseClassifierModel(configuration: MLModelConfiguration()) else {
            return
        }
        
        
        let input = HandPoseClassifierModelInput(poses: mlMultiArray)
        
        guard let prediction = try? modelClassifier.prediction(input: input) else {
            return
        }
        
        let filtered = prediction.labelProbabilities.filter { element in
            element.value > 0.8
        }
        
        //        print()
        
        if filtered.count == 1 {
            print(filtered.first!.key)
            if filtered.first!.key == "rock" {
                if gameState == .playing {
                    playerAnswered()
                }
            }
        }
    }
}


// MARK: Game Handling
extension MainViewModel {
    
    func startGaming() {
        currentTimer = 0
        gameState = .playing
        secondsToGreen = Double(Int.random(in: 3...8))
    }
    
    func handleTimer() {
        currentTimer += 0.01
    }
    
    
    func playerAnswered() {
        let catchTime = currentTimer - secondsToGreen
        
        
        DispatchQueue.main.async {
            self.gameResult = self.responseClassify(catchTime)
            self.gameState = .finished
        }
    }
    
    func responseClassify(_ catchTime: Double) -> GameResult {
        if catchTime < 0 {
            return GameResult(isRight: false, responseClass: "Too Soon!", description: "Okay time traveller ⌛️. Sorry but this app is not for you!", time: catchTime * -1)
        } else {
            switch catchTime {
            case 0..<0.350:
                return GameResult(isRight: true, responseClass: "⚡️ Lightning Fast!", description: "You are faster than... I don’t know. Haven’t done the research yet.", time: catchTime)
            case 0.350...0.600:
                return GameResult(isRight: true, responseClass: "Average 🤷‍♂️", description: "You are just... Average...", time: catchTime)
                
            default:
                return GameResult(isRight: true, responseClass: "Mr. Cool", description: "Your slow response makes you cool. I get it. Did you look away too?", time: catchTime)
            }
            
        }
    }
}
