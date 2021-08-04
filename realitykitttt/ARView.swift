//
//  File.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/07/31.
//

import Foundation
import ARKit
import SwiftUI

struct ARViewContainer: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView

    func makeCoordinator() -> ARViewCoordinator {
        ARViewCoordinator(self)
    }

    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }

    func updateUIViewController(
        _ uiViewController: ARViewContainer.UIViewControllerType,
        context: Context) { }
}

//
class ARView: UIViewController, ARSCNViewDelegate {

    var arView: ARSCNView {
        return self.view as! ARSCNView
    }

    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.scene = SCNScene()
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        enableTapGesture()
    }

    //MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.autoenablesDefaultLighting = true
        arView.session.run(configuration, options: [])
        arView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    //MARK: - ARSCNViewDelegate
    func sessionWasInterrupted(_ session: ARSession) {}

    func sessionInterruptionEnded(_ session: ARSession) {}

    func session(_ session: ARSession, didFailWithError error: Error) {}

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}

}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        self.arView.addSubview(coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
}

//MARK: - Gestures
extension ARView {

    func enableTapGesture() {
        let longPressGestureRecongiser = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(recognizer: )))
        longPressGestureRecongiser.minimumPressDuration = 0.1
        self.arView.addGestureRecognizer(longPressGestureRecongiser)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if  recognizer.state != .ended {return }
        let sceneView = recognizer.view as! ARSCNView
        let tapLocation = recognizer.location(in: sceneView)
        let query = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)

        // check to see if hitting the plane
        guard let result = sceneView.session.raycast(query!).first else { return }

        let searchResults = sceneView.hitTest(tapLocation)
        print(searchResults.count)
        // check to see if hitting existing node
        print("tap")
        for searchResult in searchResults.filter({ $0.node.name != nil }) {
            print(searchResult.node.name ?? "")
            if searchResult.node.name == "landmark" {
                // display message
                print("display message")
                return
            }
        }
        addLandmark(hitTestResult: result)
    }

    func addLandmark(hitTestResult: ARRaycastResult) {
        print("adding landmark")
        let landmarkNode = SCNNode(geometry: SCNPlane(width: 0.15, height: 0.15))
        let landmarkImage = SCNNode(geometry: SCNPlane(width: 0.075, height: 0.075))
        landmarkImage.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "dagaz")
        landmarkImage.geometry?.firstMaterial?.isDoubleSided = true
        landmarkImage.name = "landmark"

        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        landmarkNode.name = "landmark"
        landmarkNode.geometry?.firstMaterial?.diffuse.contents = UIColor(.red)
        landmarkImage.geometry?.firstMaterial?.isDoubleSided = true
        landmarkNode.position = SCNVector3(thirdColumn.x, thirdColumn.y + 0.0005, thirdColumn.z)
        landmarkNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        landmarkImage.position = SCNVector3(0, 0.001, 0)

        landmarkNode.addChildNode(landmarkImage)
        self.arView.scene.rootNode.addChildNode(landmarkNode)
    }

    func createFloor(_ planeAnchor: ARPlaneAnchor) -> SCNNode? {
        let sparklesSCN = SCNScene(named: "artt.scnassets/sparkles.scn")
        if let node = sparklesSCN?.rootNode.childNode(withName: "sparkles", recursively: false) {
            node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            return node
        }
        return nil
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("new flat surface detected")
        node.addChildNode(createFloor(planeAnchor)!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("updating floor anchor")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        node.addChildNode(createFloor(planeAnchor)!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("removed floor anchor")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer

    init(_ control: ARViewContainer) {
        self.arVC = control
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {

    }
}

extension Int {
    var degreesToRadians: Double {return Double(self) * .pi/180}
}
