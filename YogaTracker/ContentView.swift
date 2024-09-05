//
//  ContentView.swift
//  YogaTracker
//
//  Created by Vivek Singh on 20/08/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var poseDetectionViewModel = PoseDetectionViewModel()
    @StateObject private var cameraViewModel: CameraViewModel
    
    init() {
        let poseVM = PoseDetectionViewModel()
        _cameraViewModel = StateObject(wrappedValue: CameraViewModel(poseDetectionViewModel: poseVM))
        _poseDetectionViewModel = StateObject(wrappedValue: poseVM)
    }
    
    var body: some View {
        ZStack {
            CameraView(cameraViewModel: cameraViewModel)
            PoseOverlayView(poseDetectionViewModel: poseDetectionViewModel)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cameraViewModel.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
