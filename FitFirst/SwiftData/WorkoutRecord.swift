//
//  WorkoutRecord.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/17/24.
//

import Foundation
import SwiftData

@Model
class WorkoutRecord: Identifiable {
    var id: UUID
    var exerciseName: String
    var date: Date
    var reps: Int
    var duration: Double
    var caloriesBurned: Double
    var intensity: Double

    init(id: UUID = UUID(), exerciseName: String, date: Date, reps: Int, duration: Double, caloriesBurned: Double, intensity: Double) {
        self.id = id
        self.exerciseName = exerciseName
        self.date = date
        self.reps = reps
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.intensity = intensity
    }
}
