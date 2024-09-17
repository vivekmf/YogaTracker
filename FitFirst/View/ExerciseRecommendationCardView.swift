//
//  ExerciseRecommendationCardView.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/10/24.
//

import Foundation
import SwiftUI

struct ExerciseRecommendationCardView: View {
    var exerciseName: String
    var duration: String
    var level: String
    var category: String
    var imageName: String
    var comingSoon: Bool
    
    var body: some View {
        if comingSoon {
            HStack(spacing: 15) {
                Image(imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(exerciseName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(category)
                            .padding(5)
                            .padding(.trailing, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 35)
                                    .fill(categoryColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 40)
                                            .stroke(categoryColor.opacity(0.4), lineWidth: 2)
                                    )
                            )
                            .foregroundColor(Color.white)
                    }
                    
                    HStack {
                        Label(duration, systemImage: "clock")
                            .foregroundColor(.gray)
                        Label(level, systemImage: "flag")
                            .foregroundColor(.gray)
                    }
                    
                    // Display "Coming Soon" if the exercise is unavailable
                    Text("Coming Soon")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .disabled(true) // Disable interaction
        } else {
            // Normal clickable view if not coming soon
            NavigationLink(destination: ContentView()) {
                HStack(spacing: 15) {
                    Image(imageName)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(exerciseName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text(category)
                                .padding(5)
                                .padding(.trailing, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(categoryColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(categoryColor.opacity(0.4), lineWidth: 2)
                                        )
                                )
                                .foregroundColor(Color.white)
                        }
                        
                        HStack {
                            Label(duration, systemImage: "clock")
                                .foregroundColor(.gray)
                            Label(level, systemImage: "flag")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
        }
    }
    
    var categoryColor: Color {
        switch category {
        case "Cardio":
            return Color.green
        case "Muscle":
            return Color.orange
        case "Strength":
            return Color.purple
        default:
            return Color.gray
        }
    }
}
