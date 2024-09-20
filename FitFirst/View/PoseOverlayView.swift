//
//  PoseOverlayView.swift
//  FitFirst
//
//  Created by Vivek Singh on 20/08/24.
//

import Foundation
import SwiftUI
import Vision
import SwiftData

struct PoseOverlayView: View {
    @ObservedObject var poseDetectionViewModel: PoseDetectionViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var deviceOrientation: UIDeviceOrientation = .portrait
    @State private var isMirrored: Bool = true
    @State private var timeElapsed: Int = 0
    @State private var caloriesBurned: Double = 0.0
    @State private var isCountingDown: Bool = true
    @State private var countdown: Int = 5
    @State private var timer: Timer?
    @State private var weightInKg: Double = 80.2
    @State private var intensity: Double = 3.5
    @State private var heightInMeters: Double = 1.75

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
                
                // Countdown overlay
                if isCountingDown {
                    Text("\(countdown > 0 ? "\(countdown)" : "Go!")")
                        .font(.system(size: 64))
                        .bold()
                        .foregroundColor(.white)
                        .transition(.opacity)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear(perform: startCountdown)
                } else {
                    VStack {
                        // Exercise name, count, and calories
                        HStack {
                            Spacer()
                            
                            Text("\(poseDetectionViewModel.exerciseName) Count: \(poseDetectionViewModel.exerciseCount)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding()
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Timer and calorie burn
                        HStack {
                            Text("Time: \(timeElapsed) sec")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            
                            Spacer()
                            
                            Text(String(format: "Calories: %.2f", caloriesBurned))
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding()
                        .padding(.bottom)
                    }
                }
            }
            .onAppear {
                self.setupOrientationObserver()
                self.fetchUserProfile()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
                self.stopTimer()
                self.saveWorkoutRecord()
            }
            .background(Color.black.opacity(0.5))
        }
    }
    
    private func fetchUserProfile() {
        let fetchRequest = FetchDescriptor<UserProfile>()
        do {
            if let userProfile = try modelContext.fetch(fetchRequest).first {
                self.weightInKg = userProfile.weight
                self.heightInMeters = userProfile.height / 100.0
            }
        } catch {
            print("Error fetching UserProfile: \(error)")
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                isCountingDown = false
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
            calculateCalories()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func calculateCalories() {
        // Calories burned per minute = .0175 x MET x weight (in kilograms)
        let caloriesPerMinute = 0.0175 * intensity * weightInKg
        let caloriesPerSecond = caloriesPerMinute / 60.0
        caloriesBurned += caloriesPerSecond
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
    
    private func saveWorkoutRecord() {
        let workoutRecord = WorkoutRecord(
            exerciseName: poseDetectionViewModel.exerciseName,
            date: Date(),
            reps: poseDetectionViewModel.exerciseCount,
            duration: Double(timeElapsed),
            caloriesBurned: caloriesBurned,
            intensity: intensity
        )
        
        // Save to SwiftData
        modelContext.insert(workoutRecord)
        do {
            try modelContext.save()
        } catch {
            print("Error saving workout record: \(error.localizedDescription)")
        }
    }
}
