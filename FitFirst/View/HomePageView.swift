//
//  HomepageView.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/10/24.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @State private var progress: CGFloat = 0.0
    @State private var percentage: Int = 0
    
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
                    
                    // Progress Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Progress")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("Demo Statistics")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .italic()
                                        .foregroundColor(.orange)
                                }
                                
                                HStack {
                                    Text("Squatting")
                                        .padding(5)
                                        .padding(.trailing, 5)
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
                                    Label("10 Mins", systemImage: "clock")
                                        .foregroundColor(.gray)
                                    
                                    Label("Beginner", systemImage: "flag.pattern.checkered")
                                        .foregroundColor(.gray)
                                }
                                
                                HStack {
                                    Label("15 / 20 Squats", systemImage: "checkmark.circle")
                                        .foregroundColor(.gray)
                                    
                                    Label("8 mins", systemImage: "timer")
                                        .foregroundColor(.gray)
                                    
                                }
                                .padding(.top, 5)
                                
                                HStack {
                                    Label("50 kcal", systemImage: "flame")
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
                                startProgressAnimation()
                            }
                        }
                        
                        NavigationLink(destination: ContentView()) {
                            HStack {
                                Text("Continue the workout")
                                    .font(.system(size: 21, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer() // Spacer after the text
                                
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
    
    func startProgressAnimation() {
        let animationDuration: TimeInterval = 1.0
        let steps = 72
        let stepDuration = animationDuration / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                percentage = step
                progress = CGFloat(step) / 100.0
            }
        }
    }
}
