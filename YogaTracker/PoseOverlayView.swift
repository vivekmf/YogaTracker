//
//  PoseOverlayView.swift
//  YogaTracker
//
//  Created by Vivek Singh on 20/08/24.
//

import SwiftUI
import Vision

struct PoseOverlayView: View {
    @ObservedObject var poseDetectionViewModel: PoseDetectionViewModel
    @State private var deviceOrientation: UIDeviceOrientation = .portrait
    @State private var isMirrored: Bool = true
    
    private let keypointColors: [Color] = [
        .red, .green, .blue, .cyan, .yellow, .pink.opacity(0.5),
        .orange, .purple, .pink, .gray, .black, .white,
        .indigo, .teal, .brown, .mint, .yellow.opacity(0.5), .green.opacity(0.5)
    ]
    
    private let connectionColors: [Color] = [
        .red, .green, .blue, .cyan, .yellow, .purple, .orange,
        .pink, .gray, .black, .white, .indigo, .teal, .brown
    ]
    
    private let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.leftEye, .rightEye), (.leftEye, .leftShoulder), (.rightEye, .rightShoulder),
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist), (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist), (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
        (.leftHip, .rightHip), (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle), (.nose, .leftEye),
        (.nose, .rightEye), (.nose, .leftEar), (.nose, .rightEar), (.neck, .leftShoulder),
        (.neck, .rightShoulder), (.neck, .nose)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw keypoints with colors
                ForEach(poseDetectionViewModel.joints.keys.sorted { $0.rawValue.rawValue < $1.rawValue.rawValue }, id: \.self) { joint in
                    if let point = poseDetectionViewModel.joints[joint] {
                        let adjustedPoint = self.adjustedPosition(for: point, in: geometry.size)
//                        Text(joint.rawValue.rawValue)
//                            .foregroundColor(.white)
//                            .position(adjustedPoint)
                        Circle()
                            .fill(keypointColors.randomElement() ?? .white)
                            .frame(width: 10, height: 10)
                            .position(adjustedPoint)
                    }
                }
                
                // Draw connections between keypoints
                ForEach(connections.indices, id: \.self) { index in
                    let (start, end) = connections[index]
                    if let startPoint = poseDetectionViewModel.joints[start], let endPoint = poseDetectionViewModel.joints[end] {
                        let adjustedStart = self.adjustedPosition(for: startPoint, in: geometry.size)
                        let adjustedEnd = self.adjustedPosition(for: endPoint, in: geometry.size)
                        Path { path in
                            path.move(to: adjustedStart)
                            path.addLine(to: adjustedEnd)
                        }
                        .stroke(connectionColors[index % connectionColors.count], lineWidth: 2)
                    }
                }
                
                // Display exercise data: exercise name and count
                VStack {
                    HStack {
                        Text("Exercise: \(poseDetectionViewModel.exerciseName)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        Text("Count: \(poseDetectionViewModel.exerciseCount)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .onAppear {
                self.setupOrientationObserver()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            }
            .background(Color.black.opacity(0.5))
        }
    }
    
    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            self.deviceOrientation = UIDevice.current.orientation
        }
    }
    
    private func adjustedPosition(for point: CGPoint, in size: CGSize) -> CGPoint {
        var position = CGPoint(x: point.x * size.width, y: point.y * size.height)
        
        // Adjust for mirrored feed (e.g., front camera)
        if isMirrored {
            position.x = size.width - position.x
        }
        
        return position
    }
}
