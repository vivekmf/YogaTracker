//
//  PoseDetectionViewModel.swift
//  FitFirst
//
//  Created by Vivek Singh on 20/08/24.
//

import Foundation
import SwiftUI
import Vision
import CoreGraphics

class PoseDetectionViewModel: ObservableObject {
    @Published var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    @Published var exerciseName: String = "Squat"
    @Published var exerciseCount: Int = 0
    @Published var estimatedHeight: Double = 0.0  // Publish height to UI
    
    private var inBottomPosition: Bool = false
    private var sequenceRequestHandler = VNSequenceRequestHandler()
    
    // Process frame to detect human pose
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest(completionHandler: handlePoseDetection)
        
        do {
            try sequenceRequestHandler.perform([request], on: pixelBuffer)
        } catch {
            print("Error performing pose detection: \(error)")
        }
    }
    
    // Handle pose detection results
    private func handlePoseDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        if let firstObservation = observations.first {
            processObservation(firstObservation)
        }
    }
    
    // Process detected observation and extract joint data
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        var detectedJoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        let allJoints: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck, .leftEye, .rightEye, .leftEar, .rightEar,
            .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
            .leftWrist, .rightWrist, .leftHip, .rightHip,
            .leftKnee, .rightKnee, .leftAnkle, .rightAnkle
        ]
        
        for jointName in allJoints {
            if let recognizedPoint = try? observation.recognizedPoint(jointName),
               recognizedPoint.confidence > 0.1 {
                detectedJoints[jointName] = CGPoint(x: recognizedPoint.location.x, y: 1 - recognizedPoint.location.y)
            }
        }
        
        DispatchQueue.main.async {
            self.joints = detectedJoints
            self.checkSquatForm()
            self.calculateBodyHeight() // Calculate height
        }
    }
    
    // Check squat form and track exercise count
    private func checkSquatForm() {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle] else { return }
        
        let hipY = (leftHip.y + rightHip.y) / 2
        let kneeY = (leftKnee.y + rightKnee.y) / 2
        
        // Checking legs are not crossed
        if (leftKnee.x > rightKnee.x) && (leftAnkle.x > rightAnkle.x) {
            if kneeY < hipY && !inBottomPosition {
                inBottomPosition = true
            } else if kneeY > hipY && inBottomPosition {
                inBottomPosition = false
                exerciseCount += 1
            }
        } else {
            print("Legs should not be crossed with each other. They should be separated and in a straight line.")
        }
    }

    // Calculate height of the person using head and ankle joints
    private func calculateBodyHeight() {
        guard let nose = joints[.nose],  // Head joint (e.g., nose)
              let leftAnkle = joints[.leftAnkle],  // Foot joint (e.g., left ankle)
              let rightAnkle = joints[.rightAnkle] else {
            return
        }
        
        // Average the ankle points to get a more accurate foot position
        let footY = (leftAnkle.y + rightAnkle.y) / 2
        
        // Calculate vertical distance between nose and foot in normalized space
        let normalizedHeight = footY - nose.y
        
        // Convert normalized height to estimated real-world height using an assumed scaling factor
        // Assuming the frame captures the person standing at a distance where 1.0 normalized height = 1.75 meters
        let scalingFactor = 1.75 // Adjust this based on camera calibration and real-world setup
        let realWorldHeight = normalizedHeight * scalingFactor
        
        print("Height Estimation: \(realWorldHeight)")
        
        DispatchQueue.main.async {
            self.estimatedHeight = realWorldHeight
        }
    }
}
