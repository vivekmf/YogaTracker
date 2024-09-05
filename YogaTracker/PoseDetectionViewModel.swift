//
//  PoseDetectionViewModel.swift
//  YogaTracker
//
//  Created by Vivek Singh on 20/08/24.
//

import Foundation
import SwiftUI
import Vision

class PoseDetectionViewModel: ObservableObject {
    @Published var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    @Published var movementHistory: [VNHumanBodyPoseObservation.JointName: [CGPoint]] = [:]
    
    private var sequenceRequestHandler = VNSequenceRequestHandler()
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest(completionHandler: handlePoseDetection)
        
        do {
            try sequenceRequestHandler.perform([request], on: pixelBuffer)
        } catch {
            print("Error performing pose detection: \(error)")
        }
    }
    
    private func handlePoseDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        if let firstObservation = observations.first {
            processObservation(firstObservation)
        }
    }
    
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
                
                // Store the joint movement history for tracking over time
                if movementHistory[jointName] != nil {
                    movementHistory[jointName]?.append(CGPoint(x: recognizedPoint.location.x, y: 1 - recognizedPoint.location.y))
                } else {
                    movementHistory[jointName] = [CGPoint(x: recognizedPoint.location.x, y: 1 - recognizedPoint.location.y)]
                }
            }
        }
        
        DispatchQueue.main.async {
            self.joints = detectedJoints
            self.checkForExercisePatterns()
        }
    }
    
    // Example: Check for specific exercise patterns (can be expanded for multiple exercises)
    private func checkForExercisePatterns() {
        checkSquatForm()
        checkArmRaise()
        // Add more exercises here
    }
    
    private func checkSquatForm() {
        guard let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle] else {
            return
        }
        
        // Example: Check for squat position based on joint angles or relative positions
        let hipKneeDiffY = abs(leftHip.y - leftKnee.y)
        let kneeAnkleDiffY = abs(leftKnee.y - leftAnkle.y)
        
        if hipKneeDiffY > kneeAnkleDiffY {
            print("Squat detected!")
        }
    }
    
    private func checkArmRaise() {
        guard let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder],
              let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist] else {
            return
        }
        
        // Example: Detect if arms are raised above shoulders
        if leftWrist.y < leftShoulder.y && rightWrist.y < rightShoulder.y {
            print("Arms raised!")
        }
    }
}
