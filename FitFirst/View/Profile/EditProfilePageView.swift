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
    
    @Binding var userProfile: UserProfile
    
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var tempSex: String
    
    let sexOptions = ["Male", "Female", "Other"]
    
    init(userProfile: Binding<UserProfile>) {
        self._userProfile = userProfile
        self._tempSex = State(initialValue: userProfile.wrappedValue.sex.isEmpty ? "Male" : userProfile.wrappedValue.sex)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Picture Section
                Section(header: Text("Profile Picture").font(.headline).foregroundColor(.gray)) {
                    HStack {
                        Spacer()
                        VStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.green.opacity(0.6), lineWidth: 3))
                                    .shadow(color: .green.opacity(0.4), radius: 10)
                            } else if let imageData = userProfile.profilePicture,
                                      let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.green.opacity(0.6), lineWidth: 3))
                                    .shadow(color: .green.opacity(0.4), radius: 10)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.green)
                                    .cornerRadius(6)
                            }
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                }
                
                // Basic Information Section
                Section(header: Text("Basic Information").font(.headline).foregroundColor(.gray)) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                        TextField("Name", text: $userProfile.name)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("Email", text: $userProfile.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.gray)
                        TextField("Phone Number", text: $userProfile.phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        DatePicker("Date of Birth", selection: $userProfile.dateOfBirth, displayedComponents: .date)
                            .labelsHidden()
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.gray)
                        Picker("Sex", selection: $tempSex) {
                            ForEach(sexOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                // Physical Information Section
                Section(header: Text("Physical Information").font(.headline).foregroundColor(.gray)) {
                    HStack {
                        Text("Weight (kg)")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("Weight", value: $userProfile.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                            .foregroundColor(.gray)
                        Spacer()
                        TextField("Height", value: $userProfile.height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .frame(width: 100)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Convert UIImage to Data before saving
                        if let image = profileImage {
                            userProfile.profilePicture = image.pngData()
                        }
                        // Update sex from tempSex
                        userProfile.sex = tempSex
                        
                        // Insert the userProfile into the context only if it's new
                        context.insert(userProfile)
                        
                        // Save changes to the context
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            print("Failed to save changes: \(error)")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}
