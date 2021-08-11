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

    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }

    func updateUIViewController(
        _ uiViewController: ARViewContainer.UIViewControllerType,
        context: Context) { }
}


class ARView: UIViewController, ARSCNViewDelegate {
    lazy var planes = [OverlayPlane]()
    lazy var landmarks = [Landmark]()
    var messages: [String: Message] = [
        "0": Message(tagID: "0", body: "aaaaaa", sender: "0"),
        "1": Message(tagID: "1", body: "bbbbbb", sender: "1")
    ]

    var message: Message!
    var numberOfMessages = 2
    var numberOfPlacedMessages = 0
    var landmarkMap: LandmarkMap!

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

//MARK: - Gestures
extension ARView {

    func enableTapGesture() {
        let tapGestureRecongiser = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer: )))
        self.arView.addGestureRecognizer(tapGestureRecongiser)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let tapLocation = recognizer.location(in: sceneView)
        let query = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)

        // check to see if hitting the plane
        guard let result = sceneView.session.raycast(query!).first else { return }

        let searchResults = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.searchMode: 1] )
        print(searchResults.count)
        // check to see if hitting existing node
        print("tap")
        for searchResult in searchResults.filter({ $0.node.name != nil }) {
            print("node name:\(searchResult.node.name ?? "")")
            let name = searchResult.node.name ?? ""
            if name.contains("landmark") {
                // display message
                addMessage(id: String(name.suffix(name.count-8)), at: getPosition(of: result))
                return
            }
        }
    }

    func addLandmark(at position: SCNVector3, for id: String) -> SCNNode {
        print("adding landmark")
        let landmarkNode = Landmark(tagID: id)
        landmarkNode.position = position
        return landmarkNode
    }

    func addMessage(id: String, at position: SCNVector3) {
        print("adding message")
        //link to repo
        if message != nil {
            message.removeFromParentNode()
        }
        message = messages[id]
        message.position = SCNVector3(position.x, 0, position.z)
        self.arView.scene.rootNode.addChildNode(message)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        print("new flat surface detected")
        let plane = OverlayPlane(anchor: planeAnchor)
        let anchorCenterX = planeAnchor.center.x
        let anchorCenterY = planeAnchor.center.y
        landmarkMap = LandmarkMap(width: plane.width, height: plane.height, nodeDistance: 0.05, centerX: anchorCenterX, centerY: anchorCenterY)

        self.planes.append(plane)
        node.addChildNode(plane)
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

        if let existingPlane = plane {
            existingPlane.update(anchor: planeAnchor)
            if let map = landmarkMap {
                let anchorCenterX = existingPlane.anchor.center.x
                let anchorCenterY = existingPlane.anchor.center.y

                map.update(width: existingPlane.width, height: existingPlane.height, centerX: anchorCenterX, centerY: anchorCenterY)
            }
            addLandmarks(node: node, width: existingPlane.width, height: existingPlane.height)
        }
    }

    private var isMessageToAdd: Bool {
        numberOfPlacedMessages < numberOfMessages
    }

    func addCircle(at position: SCNVector3) -> SCNNode {
        let circleNode = CirclePlane()
        circleNode.position = position
        return circleNode
    }
    
    func addLandmarks(node: SCNNode, width: Float, height: Float)  {
        if !isMessageToAdd { return }
        var randomPointGen = RandomPointGenerator()
        let numberOfMessages = numberOfMessages - numberOfPlacedMessages
        let randomPoints = randomPointGen.generatePoints(numPoints: numberOfMessages, maxWidth: width, maxLength: height)
//        let location = SCNVector3(node.position.x, node.position.y + 0.01, node.position.y)
//        self.arView.scene.rootNode.addChildNode(self.addCircle(at: location))
//        DispatchQueue.main.async {
//                     self.arView.scene.rootNode.addChildNode(self.addCircle(at: location))
//                 }
        print("Avaliable Spots: \(landmarkMap.avaliableSpots)")
        print("Total Spots: \(landmarkMap.availablityMap.count)")
        if !landmarkMap.spaceAvailable {return}
        for i in 0..<landmarkMap.avaliableSpots {
            print(i)
            let gridLocation = landmarkMap.getRandomPosition()
            let location = SCNVector3(node.position.x + gridLocation!.0, node.position.y + 0.01, node.position.z + gridLocation!.1)
            DispatchQueue.main.async {
                self.arView.scene.rootNode.addChildNode(self.addCircle(at: location))

        }
//        for i in 0 ..< messages.count {
//            let location = SCNVector3 ( node.position.x + Float(randomPoints[i].x),
//                                        node.position.y + 0.01,
//                                        node.position.z + Float(randomPoints[i].y)
//            )
//            DispatchQueue.main.async {
//                self.arView.scene.rootNode.addChildNode(self.addLandmark(at: location, for: Array(self.messages.keys)[i]))
//                self.numberOfPlacedMessages += 1
//            }
//        }
        }

    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//        print("removed floor anchor")
        node.enumerateChildNodes { (childNode, _) in
            //remove avaliable capacity
            childNode.removeFromParentNode()
        }
    }
}

extension Int {
    var degreesToRadians: Double {return Double(self) * .pi/180}
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

func addBloom() -> [CIFilter]? {
    let bloomFilter = CIFilter(name: "CIBloom")!
    bloomFilter.setValue(10, forKey: "inputIntensity")
    bloomFilter.setValue(30, forKey: "inputRadius")

    return [bloomFilter]
}
