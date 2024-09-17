//
//  CameraViewModel.swift
//  FitFirst
//
//  Created by Vivek Singh on 20/08/24.
//

import AVFoundation
import SwiftUI
import Vision

class CameraViewModel: NSObject, ObservableObject {
    var captureSession: AVCaptureSession!
    private var videoOutput: AVCaptureVideoDataOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var poseDetectionViewModel: PoseDetectionViewModel
    
    init(poseDetectionViewModel: PoseDetectionViewModel) {
        self.poseDetectionViewModel = poseDetectionViewModel
        super.init()
        setupCamera()
        setupOrientationObserver()
        adjustCameraOrientation()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else { return }
        
        captureSession.addInput(videoInput)
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func startCameraSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopCameraSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func setupOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func handleOrientationChange() {
        adjustCameraOrientation()
    }
    
    private func adjustCameraOrientation() {
        guard let connection = videoOutput.connection(with: .video) else { return }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            connection.videoRotationAngle = 180
        case .landscapeRight:
            connection.videoRotationAngle = 0
        case .portraitUpsideDown:
            connection.videoRotationAngle = 270
        case .portrait:
            connection.videoRotationAngle = 90
        default:
            connection.videoRotationAngle = 90
        }
        
        // Update preview layer orientation
        DispatchQueue.main.async {
            self.previewLayer?.frame = UIScreen.main.bounds
            self.previewLayer?.connection?.videoRotationAngle = connection.videoRotationAngle
        }
    }
    
    func switchCamera() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        // Stop the session before changing the configuration
        captureSession.stopRunning()
        
        // Begin configuration to change camera input
        captureSession.beginConfiguration()
        
        // Remove the current input
        captureSession.removeInput(currentInput)
        
        // Determine the new camera position
        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              captureSession.canAddInput(newInput) else {
            // In case of failure, add the original input back
            captureSession.addInput(currentInput)
            captureSession.commitConfiguration()
            captureSession.startRunning()
            return
        }
        
        // Add the new input and commit the configuration
        captureSession.addInput(newInput)
        captureSession.commitConfiguration()
        
        // Start the session again after configuration is committed
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        DispatchQueue.main.async {
            self.previewLayer?.removeFromSuperlayer()
            self.previewLayer = layer
        }
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        poseDetectionViewModel.processFrame(pixelBuffer)
    }
}
