//
//  UserProfile.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/19/24.
//

import Foundation
import SwiftData

@Model
class UserProfile {
    // Properties
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return components.year ?? 0
    }
    var sex: String
    var weight: Double
    var height: Double
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date // Store date of birth
    var profilePicture: Data? // Optional data to store the profile picture
    
    // Initializer
    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date,
        sex: String,
        weight: Double,
        height: Double,
        email: String,
        phoneNumber: String,
        profilePicture: Data? = nil // Default value is nil
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.weight = weight
        self.height = height
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePicture = profilePicture
    }
}
