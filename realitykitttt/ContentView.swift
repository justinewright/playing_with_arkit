//
//  ContentView.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/07/30.
//

import SwiftUI
import UIKit
import RealityKit
import ARKit
//
//extension ARView: ARCoachingOverlayViewDelegate {
//    func addCoaching() {
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.delegate = self
//        coachingOverlay.session = self.session
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        coachingOverlay.goal = .horizontalPlane
//        self.addSubview(coachingOverlay)
//    }
//
//    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        <#code#>
//    }
//}
//
//struct ARViewContainer: UIViewRepresentable {
//
//    func makeCoordinator() -> Coordinator {
//        ARViewCoordinator(self)
//    }
//
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = .horizontal
//        arView.session.run(config, options: [])
//    }
//}
//
//class ARViewCoordinator: NSObject, ARSessionDelegate {
//    var arVC: ARViewContainer
//
//    override init(_ controller: ARViewContainer) {
//        self.arVC = controller
//    }
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        <#code#>
//    }
//}

struct ContentView: View {
    var body: some View {
        return ARViewContainer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
