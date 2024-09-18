//
//  HomepageView.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/10/24.
//

import SwiftUI
import SwiftData

struct HomePageView: View {
    @State private var progress: CGFloat = 0.0
    @State private var percentage: Int = 0
    
    // Using @Query to fetch WorkoutRecord data
    @Query(sort: \WorkoutRecord.date, order: .reverse) var workoutRecords: [WorkoutRecord]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Welcome message with user information
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back 👋")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text("Vivek Singh")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Image("user_profile_picture")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Check if workout records are available
                    if let latestWorkout = workoutRecords.first {
                        // Progress Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Progress")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text(latestWorkout.exerciseName)
                                            .padding(2)
                                            .padding(.trailing, 5)
                                            .padding(.horizontal, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 22)
                                                    .fill(Color.green)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.green.opacity(0.4), lineWidth: 2)
                                                    )
                                            )
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                    
                                    HStack {
                                        Label("\(latestWorkout.duration.formatted(.number.precision(.fractionLength(0)))) Min", systemImage: "clock")
                                            .foregroundColor(.gray)
                                        
                                        Label("Intensity: \(latestWorkout.intensity.formatted(.number.precision(.fractionLength(1))))", systemImage: "flag.pattern.checkered")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Label("\(latestWorkout.reps) / 20 Reps", systemImage: "checkmark.circle")
                                            .foregroundColor(.gray)
                                        
                                        Label("\(latestWorkout.duration.formatted(.number.precision(.fractionLength(0)))) Sec", systemImage: "timer")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 5)
                                    
                                    HStack {
                                        Label(
                                            "\(formattedCalories(latestWorkout.caloriesBurned))",
                                            systemImage: "flame"
                                        )
                                        .foregroundColor(.gray)
                                    }
                                    .padding(.top, 5)
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    GeometryReader { geometry in
                                        let size = min(geometry.size.width, geometry.size.height)
                                        let lineWidth = size * 0.2
                                        let percentageFontSize = size * 0.33
                                        let symbolFontSize = size * 0.23
                                        let symbolPadding = size * 0.05
                                        
                                        Circle()
                                            .stroke(lineWidth: lineWidth)
                                            .opacity(0.3)
                                            .foregroundColor(Color.green)
                                        
                                        Circle()
                                            .trim(from: 0.0, to: progress)
                                            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                            .foregroundColor(Color.green)
                                            .rotationEffect(Angle(degrees: 270))
                                        
                                        HStack(spacing: 4) {
                                            Text("\(percentage)")
                                                .font(.system(size: percentageFontSize, weight: .bold, design: .rounded))
                                                .foregroundColor(.green)
                                            
                                            Text("%")
                                                .font(.system(size: symbolFontSize, weight: .bold, design: .rounded))
                                                .foregroundColor(.green)
                                                .padding(.leading, -symbolPadding)
                                        }
                                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .onAppear {
                                    startProgressAnimation(reps: latestWorkout.reps, targetReps: 20)
                                }
                            }
                            
                            NavigationLink(destination: ContentView()) {
                                HStack {
                                    Text("Continue the workout")
                                        .font(.system(size: 21, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                        .foregroundColor(.black)
                                        .background(
                                            Circle()
                                                .foregroundColor(.white)
                                                .frame(width: 41, height: 41)
                                                .overlay(Circle().stroke(Color.white))
                                        )
                                        .padding(.leading, 10)
                                }
                                .padding()
                                .background(Color.black)
                                .cornerRadius(33)
                            }
                            .padding(.vertical)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    } else {
                        // If no workouts, show a placeholder
                        Text("No workout records found. Start your workout to see progress here.")
                            .font(.system(size: 18, weight: .medium))
                            .padding(.top, 20)
                            .padding(.horizontal)
                    }
                    
                    // Recommendations Section
                    Text("Recommendation")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    VStack(spacing: 15) {
                        ExerciseRecommendationCardView(exerciseName: "Squat", duration: "15 minutes", level: "Beginner", category: "Cardio", imageName: "squat_image", comingSoon: false)
                        ExerciseRecommendationCardView(exerciseName: "Push Ups", duration: "30 minutes", level: "Middle", category: "Muscle", imageName: "push_ups_image", comingSoon: true)
                        ExerciseRecommendationCardView(exerciseName: "Lunges", duration: "2 hours", level: "Pro Suhu", category: "Strength", imageName: "lungs_image", comingSoon: true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true) // Hides the default navigation bar
        }
    }
    
    private func formattedCalories(_ calories: Double) -> String {
        if calories >= 1000 {
            // Display in kilocalories (kcal)
            let kcal = calories / 1000
            return "\(kcal.formatted(.number.precision(.fractionLength(1)))) kcal"
        } else {
            // Display in calories (cal)
            return "\(calories.formatted(.number.precision(.fractionLength(1)))) cal"
        }
    }
    
    func startProgressAnimation(reps: Int, targetReps: Int) {
        let animationDuration: TimeInterval = 1.0
        let progressPercentage = min(CGFloat(reps) / CGFloat(targetReps), 1.0)
        let steps = Int(progressPercentage * 100)
        let stepDuration = animationDuration / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                percentage = step
                progress = CGFloat(step) / 100.0
            }
        }
    }
}
