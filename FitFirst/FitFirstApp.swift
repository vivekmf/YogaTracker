//
//  FitFirstApp.swift
//  FitFirst
//
//  Created by Vivek Singh on 20/08/24.
//

import SwiftUI
import SwiftData

@main
struct FitFirstApp: App {
    @State private var container = try! ModelContainer(for: WorkoutRecord.self, UserProfile.self)
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
                .modelContainer(container)
        }
    }
}
