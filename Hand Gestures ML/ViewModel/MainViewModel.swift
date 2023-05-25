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


// MARK: Camera Frame Handling
@MainActor
class MainViewModel: ObservableObject {
    @Published var predictionLabel: String?
    @Published var gameState: GameState = .prePlay
    
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
        
        if filtered.count == 1 {
            let element = filtered.first!
            predictionLabel = "\(element.key) (Confidence: \(Int(element.value * 100))%)"
        }
    }
}


//// MARK: Game Handling
//extension MainViewModel {
//    
//}
