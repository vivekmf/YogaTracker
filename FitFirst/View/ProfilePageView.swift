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
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    Text(userProfile.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text(userProfile.email)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Profile Details
                List {
                    Section(header: Text("User Information")) {
                        HStack {
                            Text("Phone Number")
                            Spacer()
                            Text(userProfile.phoneNumber)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Date of Birth")
                            Spacer()
                            // Displaying date of birth in abbreviated format
                            Text(userProfile.dateOfBirth, style: .date)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(userProfile.age) years")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Sex")
                            Spacer()
                            Text(userProfile.sex)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\(userProfile.weight.formatted()) kg")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Height")
                            Spacer()
                            Text("\(userProfile.height.formatted()) cm")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Profile", displayMode: .inline)
                .sheet(isPresented: $isEditing) {
                    EditProfilePageView(userProfile: userProfile)
                }
            } else {
                // No profile found
                Text("No user profile found. Please create your profile.")
                    .padding()
            }
        }
    }
}
