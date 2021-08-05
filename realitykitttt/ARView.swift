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

//    func makeCoordinator() -> ARViewCoordinator {
//        ARViewCoordinator(self)
//    }

    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }

    func updateUIViewController(
        _ uiViewController: ARViewContainer.UIViewControllerType,
        context: Context) { }
}


class ARView: UIViewController, ARSCNViewDelegate {
    var planes = [OverlayPlane]()
    var numberOfMessages = 1
    var numberOfPlacedMessages = 0

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
        longPressGestureRecongiser.minimumPressDuration = 0.2
        self.arView.addGestureRecognizer(longPressGestureRecongiser)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if  recognizer.state != .ended { return }
        let sceneView = recognizer.view as! ARSCNView
        let tapLocation = recognizer.location(in: sceneView)
        let query = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)

        // check to see if hitting the plane
        guard let result = sceneView.session.raycast(query!).first else { return }

        let searchResults = sceneView.hitTest(tapLocation, options: nil)
        print(searchResults.count)
        // check to see if hitting existing node
        print("tap")
        for searchResult in searchResults.filter({ $0.node.name != nil }) {
            print("node name:\(searchResult.node.name ?? "")")
            if searchResult.node.name == "landmark" {
                // display message
                addMessage(at: getPosition(of: result))
                return
            }
        }
//        addLandmark(at: getPosition(of: result))
    }

    func getPosition(of hitTestResult: ARRaycastResult) -> SCNVector3 {

        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        return SCNVector3(thirdColumn.x - 0.001, thirdColumn.y, thirdColumn.z)
    }

    func getBound(of node: SCNNode) -> SCNVector3 {
        let minVec = node.boundingBox.min
        let maxVec = node.boundingBox.max
        return SCNVector3Make(
            maxVec.x - minVec.x,
            maxVec.y - minVec.y,
            maxVec.z - minVec.z)
    }

    func getCenterPoint(of node: SCNNode) -> SCNMatrix4 {
        let minVec = node.boundingBox.min
        let bound  = getBound(of: node)
        let dx = minVec.x + 0.5 * (bound.x)
        let dy = minVec.y + 0.5 * (bound.y)
        let dz = minVec.z + 0.5 * (bound.z)
        return SCNMatrix4MakeTranslation(dx, dy, dz)
    }

    func addLandmark(at position: SCNVector3) -> SCNNode {
        print("adding landmark")
//        let landmarkNode = SCNNode(geometry: SCNBox(width: 0.2, height: 0.01, length: 0.2, chamferRadius: 0.05))
        let plane = SCNPlane(width: 0.15, height: 0.15)
        let landmarkNode = SCNNode(geometry: plane)
        landmarkNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)

        //change center
        landmarkNode.pivot = getCenterPoint(of: landmarkNode)

        landmarkNode.name = "landmark"
        landmarkNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "dagaz")
        landmarkNode.geometry?.firstMaterial?.selfIllumination.contents = UIColor.orange
        landmarkNode.geometry?.firstMaterial?.transparency = 0.9

        landmarkNode.filters = addBloom()
        landmarkNode.geometry?.firstMaterial?.isDoubleSided = true
        landmarkNode.position = position
        return landmarkNode
//        self.arView.scene.rootNode.addChildNode(landmarkNode)
    }

    func createFloor(_ position: SCNVector3) -> SCNNode? {

//        let position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
//        return addLandmark(at: position)
        let sparklesSCN = SCNScene(named: "artt.scnassets/sparkles.scn")
        if let node = sparklesSCN?.rootNode.childNode(withName: "sparkles", recursively: false) {
            node.position = position
            return node
        }
        return nil
    }


    func addMessage(at position: SCNVector3) {
        print("adding message")

        let textGeometry = SCNText(string: "Hello", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "AmericanTypewriterCondesnsedLight", size: 16)
        textGeometry.flatness = 0
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        let textNode = SCNNode(geometry: textGeometry)
        let fontScale: Float = 0.01
        textNode.scale = SCNVector3(fontScale, fontScale, fontScale)

        //change center
        textNode.pivot = getCenterPoint(of: textNode)

        let pad: Float = 5
        let bound = getBound(of: textNode)
        let plane = SCNPlane(width: CGFloat(bound.x + pad)*CGFloat(fontScale),
                             height: CGFloat(bound.y + pad)*CGFloat(fontScale) )

        plane.cornerRadius = 0.2

        let bubbleNode = SCNNode(geometry: plane)
        bubbleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        bubbleNode.position =  SCNVector3(position.x ,0 , position.z)
        bubbleNode.addChildNode(textNode)

        self.arView.scene.rootNode.addChildNode(bubbleNode)
    }

    func updateText(text: String, atPosition position:SCNVector3) {

    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        print("new flat surface detected")
        let plane = OverlayPlane(anchor: planeAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
//        node.addChildNode(createFloor(location)!)
//        node.addChildNode(addLandmark(at: location))
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        print("updating floor anchor")
//        node.enumerateChildNodes { (childNode, _) in
//            childNode.removeFromParentNode()
//        }
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first

        if plane == nil {
            return
        }

        plane?.update(anchor: planeAnchor)
        //if there are messages to display then pick a new random area
        if numberOfPlacedMessages < numberOfMessages {
            var randomPointGen = RandomPointGenerator()
            let randomPoints = randomPointGen.generatePoints(
                numPoints: numberOfMessages - numberOfPlacedMessages,
                maxWidth: plane?.width ?? 0.1,
                maxLength: plane?.height ?? 0.1)
            randomPoints.forEach { randomPoint in
                let location = SCNVector3(
                    Float(randomPoint.x),
                    0.001,
                    Float(randomPoint.y) )
                node.addChildNode((addLandmark(at: location)))
                numberOfPlacedMessages += 1
            }

        }
//        node.addChildNode(createFloor(location)!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        print("removed floor anchor")
        node.enumerateChildNodes { (childNode, _) in
            //remove avaliable capacity
            childNode.removeFromParentNode()
        }
    }

    func addBloom() -> [CIFilter]? {
        let bloomFilter = CIFilter(name: "CIBloom")!
        bloomFilter.setValue(10, forKey: "inputIntensity")
        bloomFilter.setValue(30, forKey: "inputRadius")

        return [bloomFilter]
    }
}
// random locations
extension ARView{
    var randomPoint: CGPoint {
        CGPoint(
            x: CGFloat(arc4random()) / CGFloat(UINT32_MAX),
            y: CGFloat(arc4random()) / CGFloat(UINT32_MAX)
        )
    }

    var randomLocation: SCNVector3? {
        let sceneView = arView
        let query = sceneView.raycastQuery(from: randomPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        guard let result = sceneView.session.raycast(query!).first else { return nil }

        return SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
        )
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //check to see if message is not loaded into world
        print("updating session")
        guard let cameraTransform = session.currentFrame?.camera.transform else {return}
        let cameraPosition = SCNVector3(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )

        // check to see if hitting the plane
        let sceneView = arView
        let query = sceneView.raycastQuery(from: randomPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        guard let result = sceneView.session.raycast(query!).first else { return }

        let newPoint = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
        )

        self.arView.scene.rootNode.addChildNode(addLandmark(at: newPoint))
    }
}
class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer

    init(_ control: ARViewContainer) {
        self.arVC = control
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // todo add in status of mapping
    }
}

extension Int {
    var degreesToRadians: Double {return Double(self) * .pi/180}
}
