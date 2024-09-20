//
//  ARViewContainer.swift
//  FitFirst
//
//  Created by Vivek Singh on 9/20/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    let arView = ARView(frame: .zero)

    func makeUIView(context: Context) -> ARView {
        let config = ARBodyTrackingConfiguration()
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let bodyAnchor = anchor as? ARBodyAnchor {
                    // Access the body skeleton and use the joints to measure height
                    let skeleton = bodyAnchor.skeleton
                    if let headTransform = skeleton.modelTransform(for: .head),
                       let leftFootTransform = skeleton.modelTransform(for: .leftFoot),
                       let rightFootTransform = skeleton.modelTransform(for: .rightFoot) {
                        
                        // Average the feet positions manually by summing the translations and dividing by 2
                        let footPosition = (leftFootTransform.translation + rightFootTransform.translation) / 2
                        
                        // Get the distance between head and feet in meters
                        let heightInMeters = distance(headTransform.translation, footPosition)
                        
                        // Output the height (this can be passed to SwiftUI via Binding or State)
                        print("Height: \(heightInMeters) meters")
                    }
                }
            }
        }
    }
}

// Utility function to extract translation from 4x4 matrix
extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}
