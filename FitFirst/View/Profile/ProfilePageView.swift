//
//  ProfilePageView.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/19/24.
//

import Foundation
import SwiftUI
import SwiftData

struct ProfilePageView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var isEditing = false
    
    // Fetching the user profile data
    @Query private var userProfiles: [UserProfile]
    
    var body: some View {
        NavigationView {
            VStack {
                if let userProfile = userProfiles.first {
                    // Profile Header
                    VStack {
                        if let profilePictureData = userProfile.profilePicture,
                           let image = UIImage(data: profilePictureData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.green, lineWidth: 2))
                                .shadow(color: .green, radius: 8)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.green.opacity(6.0))
                        }
                        
                        Text(userProfile.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(userProfile.email)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Profile Details
                    List {
                        Section(header: Text("User Information").font(.headline)) {
                            ProfileInfoRow(label: "Phone Number", value: userProfile.phoneNumber)
                            ProfileInfoRow(label: "Date of Birth", value: userProfile.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                            ProfileInfoRow(label: "Age", value: "\(userProfile.age) years")
                            ProfileInfoRow(label: "Sex", value: userProfile.sex)
                            ProfileInfoRow(label: "Weight", value: "\(userProfile.weight.formatted()) kg")
                            ProfileInfoRow(label: "Height", value: "\(userProfile.height.formatted()) cm")
                        }
                        
                        Section {
                            Button(action: {
                                isEditing.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(.red)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationBarTitle("Profile", displayMode: .inline)
                    // Passing a binding using $
                    .sheet(isPresented: $isEditing) {
                        EditProfilePageView(userProfile: .constant(userProfile))
                    }
                } else {
                    // No profile found
                    VStack {
                        Text("No user profile found.")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("Please create your profile to get started.")
                            .font(.body)
                            .foregroundColor(.green.opacity(6.0))
                        
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text("Create Profile")
                                .font(.system(size: 18, weight: .bold))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

// Helper view for displaying profile information rows
struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular, design: .rounded))
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
    }
}
