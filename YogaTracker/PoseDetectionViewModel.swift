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
    @Published var exerciseName: String = "Squat"  // Example default exercise
    @Published var exerciseCount: Int = 0  // Count of completed repetitions
    
    private var inBottomPosition: Bool = false  // Tracks if user is in the bottom squat position
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
            }
        }
        
        DispatchQueue.main.async {
            self.joints = detectedJoints
            self.checkSquatForm()
        }
    }
    
    func setExercise(_ name: String, instructions: [String]) {
        exerciseName = name
        exerciseCount = 0  // Reset count
        // Display instructions to the user if needed
    }
    
    private func checkSquatForm() {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee] else { return }
        
        let hipY = (leftHip.y + rightHip.y) / 2
        let kneeY = (leftKnee.y + rightKnee.y) / 2
        
        if kneeY < hipY && !inBottomPosition {
            inBottomPosition = true
        } else if kneeY > hipY && inBottomPosition {
            inBottomPosition = false
            exerciseCount += 1
        }
    }
}
