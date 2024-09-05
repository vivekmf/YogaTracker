//
//  CameraView.swift
//  YogaTracker
//
//  Created by Vivek Singh on 22/08/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var cameraViewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraViewModel.setupCamera()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraViewModel.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        cameraViewModel.setPreviewLayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
