//
//  ContentView.swift
//  FitFirst
//
//  Created by Vivek Singh on 20/08/24.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @StateObject private var poseDetectionViewModel = PoseDetectionViewModel()
    @StateObject private var cameraViewModel: CameraViewModel
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init() {
        let poseVM = PoseDetectionViewModel()
        _poseDetectionViewModel = StateObject(wrappedValue: poseVM)
        _cameraViewModel = StateObject(wrappedValue: CameraViewModel(poseDetectionViewModel: poseVM))
    }

    var body: some View {
        ZStack {
            CameraView(cameraViewModel: cameraViewModel)
            PoseOverlayView(poseDetectionViewModel: poseDetectionViewModel)

            VStack {
                HStack {
                    // Custom back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding()
                    .padding(.top)
                    Spacer()
                }
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
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            cameraViewModel.startCameraSession()
        }
        .onDisappear {
            cameraViewModel.stopCameraSession()
        }
        .navigationBarHidden(true) // Hides the default navigation bar
    }
}
