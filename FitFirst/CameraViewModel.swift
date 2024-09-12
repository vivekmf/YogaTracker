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

        DispatchQueue.main.async {
            self.previewLayer?.frame = UIScreen.main.bounds
            self.previewLayer?.connection?.videoRotationAngle = connection.videoRotationAngle
        }
    }

    func switchCamera() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()

        captureSession.stopRunning()
        captureSession.removeInput(currentInput)

        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        } else {
            captureSession.addInput(currentInput)
        }

        captureSession.commitConfiguration()

        captureSession.startRunning()
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
