//
//  Line.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/06.
//

import Foundation
import SceneKit

extension SCNGeometry {
    class func line(from: SCNVector3, to: SCNVector3, segments: Int) ->  SCNNode {
        let distance = distanceBetween2Points(from: from, to: to)
        let cylinder = SCNCylinder(radius: 0.005, height: CGFloat(distance))
        cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = UIColor.orange

        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = getPointOnLine(from: from, to: to, percent: 0.5)
        lineNode.eulerAngles = getRotationOfLine(from: from, to: to, distance: distance)

        return lineNode
    }
}

func distanceBetween2Points(from: SCNVector3, to: SCNVector3) -> Float {
    sqrtf(
        pow((from.x - to.x), 2) +
        pow((from.y - to.y), 2) +
        pow((from.z - to.z), 2)
    )
}

func getPointOnLine(from: SCNVector3, to: SCNVector3, percent: Float) -> SCNVector3 {
    SCNVector3((from.x + to.x) * percent,
               (from.y + to.y) * percent,
               (from.z + to.z) * percent)
}

func getRotationOfLine(from: SCNVector3, to: SCNVector3, distance: Float) -> SCNVector3 {
    SCNVector3(Float.pi / 2,
               acos(to.z - from.z) / distance ,
               atan2((to.y - from.y), (to.x - from.x))
    )
}
