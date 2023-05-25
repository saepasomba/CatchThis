//
//  File.swift
//  Hand Gestures ML
//
//  Created by Sae Pasomba on 19/05/23.
//

import UIKit
import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var coordinator: Coordinator?
    
    private var frameHandler: ((UIImage) -> Void)?
     
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Handle the captured frame here
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = UIImage(ciImage: ciImage)
            
            // Pass the captured frame to the parent view
            parent.handleFrame(uiImage)
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return view
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return view
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "camera_frame_queue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update anything in this example
    }
    
    func handleFrame(_ frame: UIImage) {
        
        if let safeHandler = frameHandler {
            safeHandler(frame)
        } else {
            print("frameHandler is not defined! ")
        }
    }
    
    func onFrameCaptured(_ handler: @escaping (UIImage) -> Void) -> Self {
        var updatedView = self
        updatedView.frameHandler = handler
        
        return updatedView
    }
}
