//
//  OverlayPlane.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/05.
//

import Foundation
import SceneKit
import ARKit
import UIKit

enum BodyType: Int {
    case box = 1
    case plane = 2
}

class OverlayPlane: SCNNode {

    var anchor: ARPlaneAnchor
    private var planeGeomeotry: SCNPlane!

    private var maxCapacity: Float = 0.24
    private var currentCapacity: Float = 0

    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }

    func update(anchor: ARPlaneAnchor) {
        self.planeGeomeotry.width = CGFloat(anchor.extent.x)
        self.planeGeomeotry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)

        let planeNode = self.childNodes.first!

//        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeomeotry, options: nil))
    }

    private func setup() {
        self.planeGeomeotry = SCNPlane(
            width: CGFloat(self.anchor.extent.x),
            height: CGFloat(self.anchor.extent.z)
        )

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "grid")
        material.transparency = 0

        self.planeGeomeotry.materials = [material]

        let planeNode = SCNNode(geometry: self.planeGeomeotry)

        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1, 0, 0 )

        self.addChildNode(planeNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var width: Float {
        Float(self.planeGeomeotry.width)
    }

    var height: Float {
        self.anchor.extent.z
    }

    func canAddItem(with dimensions: CGPoint) -> Bool {
        if currentCapacity > maxCapacity { return false }

        let totalArea = width * height
        let newCapacity = currentCapacity + Float(dimensions.x * dimensions.y)/totalArea
        if newCapacity > maxCapacity { return false }

        currentCapacity = newCapacity
        return true
    }

}
