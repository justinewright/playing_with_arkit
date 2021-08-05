//
//  PointGenerator.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/05.
//

import Foundation
import CoreGraphics

protocol PointGenerator {
    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint]
}

struct RandomPointGenerator: PointGenerator {
    mutating func generatePoints(numPoints: Int, maxWidth: Float, maxLength: Float) -> [CGPoint] {
        var points = [CGPoint]()

        for _ in 0..<numPoints {
            let x = Float.random(in: -maxWidth/2 ... maxWidth/2)
            let y = Float.random(in: -maxWidth/2 ... maxWidth/2)

            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            points.append(point)
        }
        return points
    }
}
