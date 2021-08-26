//
//  Circle.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/10.
//

import Foundation
import SceneKit
import ARKit
import UIKit

class CirclePlane: SCNNode {
    var width = 0.15
    var height = 0.15

    private var planeGeomeotry: SCNPlane!

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        self.planeGeomeotry = SCNPlane(
            width: CGFloat(width),
            height: CGFloat(height)
        )
        let node = SCNNode(geometry: self.planeGeomeotry)
        node.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
        node.pivot = getCenterPoint(of: node)
        let image = UIImage(systemName: "circle")
        image?.withTintColor(.white, renderingMode: .alwaysTemplate)
        node.geometry?.firstMaterial?.diffuse.contents = image
    
        node.geometry?.firstMaterial?.transparency = 0.9

        node.geometry?.firstMaterial?.isDoubleSided = true


        self.addChildNode(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
