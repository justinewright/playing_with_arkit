//
//  LandmarkNode.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/05.
//

import Foundation
import SceneKit
import ARKit
import UIKit

class Landmark: SCNNode {
    var id: String = ""
    var width = 0.15
    var height = 0.15

    private var planeGeomeotry: SCNPlane!

    init(tagID: String = "0") {
        super.init()
        id = tagID
        setup()
    }

    private func setup() {
        self.planeGeomeotry = SCNPlane(
            width: CGFloat(width),
            height: CGFloat(height)
        )
        let landmarkNode = SCNNode(geometry: self.planeGeomeotry)
        landmarkNode.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
        landmarkNode.pivot = getCenterPoint(of: landmarkNode)
        landmarkNode.name = "landmark\(id)"
        landmarkNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "dagaz")
        landmarkNode.geometry?.firstMaterial?.selfIllumination.contents = UIColor.orange
        landmarkNode.geometry?.firstMaterial?.transparency = 0.9
        landmarkNode.filters = addBloom()
        landmarkNode.geometry?.firstMaterial?.isDoubleSided = true

        let boxGeo = SCNBox(width: CGFloat(width), height: 0.01, length: CGFloat(height), chamferRadius: 0)
        let material = SCNMaterial()
        material.transparency = 0
        boxGeo.materials = [material]
        let box = SCNNode(geometry: boxGeo)
        box.addChildNode(landmarkNode)
        box.name = "landmark\(id)"
        self.addChildNode(box)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
