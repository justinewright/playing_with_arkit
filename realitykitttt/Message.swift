//
//  Message.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/05.
//

import Foundation
import SceneKit
import ARKit
import UIKit

class Message: SCNNode {
    var id: String = ""
    var body: String = ""
    var sender: String = ""

    private var planeGeomeotry: SCNPlane!
    private var textBodyGeometry: SCNText!
    private var textSenderGeometry: SCNText!

    private var bubbleNode: SCNNode!
    private var textBodyNode: SCNNode!
    private var textSenderNode: SCNNode!
    private var textNode: SCNNode!

    private let fontScale: Float = 0.01
    private let textColour = UIColor.white

    init(tagID: String, body: String , sender: String ) {
        super.init()
        self.id = tagID
        self.body = body
        self.sender = sender
        setup()
    }

    private func setup() {
        print("displaying message")
        setUpTextBody()
        setUpTextSender()
        setUpBubble()
    }

    private func setUpTextBody() {
        textNode = SCNNode()
        textBodyGeometry = SCNText(string: self.body, extrusionDepth: 1)
        textBodyGeometry.flatness = 0
        textBodyGeometry.firstMaterial?.diffuse.contents = textColour

        textBodyNode = SCNNode(geometry: textBodyGeometry)
        textBodyNode.scale = SCNVector3(fontScale, fontScale, fontScale)
        textBodyNode.pivot = getCenterPoint(of: textBodyNode)

        let bounds = getBound(of: textBodyNode)
        textBodyNode.position = SCNVector3(0, bounds.y * fontScale / 3 , 0)

        textNode.addChildNode(textBodyNode)
    }

    private func setUpTextSender() {
        textSenderGeometry = SCNText(string: self.sender, extrusionDepth: 1)
        textSenderGeometry.flatness = 0
        textSenderGeometry.firstMaterial?.diffuse.contents = textColour

        textSenderNode = SCNNode(geometry: textSenderGeometry)
        textSenderNode.boundingBox = textBodyNode.boundingBox
        textSenderNode.scale = SCNVector3(fontScale/2, fontScale/2, fontScale/2)
        textSenderNode.pivot = getCenterPoint(of: textSenderNode)
        
        let bounds = getBound(of: textBodyNode)
        textSenderNode.position = SCNVector3(0, -bounds.y * fontScale / 2 , 0)

        textNode.addChildNode(textSenderNode)
    }

    private func setUpBubble() {
        if bubbleNode != nil {
            bubbleNode.removeFromParentNode()
        }
        let pad: Float = 5
        let bound = getBound(of: textBodyNode)
        self.planeGeomeotry = SCNPlane(
            width:  CGFloat(bound.x + pad)*CGFloat(fontScale),
            height: CGFloat(2 * bound.y + pad)*CGFloat(fontScale)
        )
        self.planeGeomeotry.cornerRadius = 0.1
        let bubbleNode = SCNNode(geometry: self.planeGeomeotry)
        bubbleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        bubbleNode.addChildNode(textNode)

        self.addChildNode(bubbleNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

