//
//  EditProfilePageView.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/19/24.
//

import SwiftUI
import SwiftData

struct EditProfilePageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context: ModelContext
    
    // User profile to edit
    var userProfile: UserProfile // Removed @Bindable
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var sex: String = ""
    @State private var weight: Double = 0.0
    @State private var height: Double = 0.0
    @State private var profileImage: UIImage?
    
    @State private var showImagePicker = false
    
    let sexOptions = ["Male", "Female", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Picture
                Section(header: Text("Profile Picture")) {
                    VStack {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Button("Change Photo") {
                            showImagePicker = true
                        }
                    }
                }
                
                // Basic Information
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    
                    Picker("Sex", selection: $sex) {
                        ForEach(sexOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                // Physical Information
                Section(header: Text("Physical Information")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Save Button
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadProfileData)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
    
    private func loadProfileData() {
        name = userProfile.name
        email = userProfile.email
        phoneNumber = userProfile.phoneNumber
        dateOfBirth = userProfile.dateOfBirth // Load the date of birth
        sex = userProfile.sex
        weight = userProfile.weight
        height = userProfile.height
        if let profileData = userProfile.profilePicture {
            profileImage = UIImage(data: profileData)
        }
    }
    
    private func saveProfile() {
        userProfile.name = name
        userProfile.email = email
        userProfile.phoneNumber = phoneNumber
        userProfile.dateOfBirth = dateOfBirth // Save the date of birth
        userProfile.sex = sex
        userProfile.weight = weight
        userProfile.height = height
        if let profileImage = profileImage {
            userProfile.profilePicture = profileImage.jpegData(compressionQuality: 0.8)
        }
        
        try? context.save()
        
        dismiss()
    }
}
