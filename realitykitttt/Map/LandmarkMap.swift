//
//  AnchorMap.swift
//  realitykitttt
//
//  Created by Justine Wright on 2021/08/06.
//

import Foundation

struct CoordPairs: Hashable {
    let x: Int
    let y: Int
}

class LandmarkMap {
    private(set) var availablityMap: [CoordPairs: Bool]!
    private var nodeDistance: Float
    private var centerX: Float
    private var centerY: Float
    private var xShift: Float
    private var yShift: Float
    private var maxCapacity: Float = 0.24

    init(width: Float, height: Float, nodeDistance: Float, centerX: Float, centerY: Float) {
        self.centerX = centerX
        self.centerY = centerY
        self.nodeDistance = nodeDistance
        xShift = 0
        yShift = 0
        genMap(width: width, height: height)
    }

    func update(width: Float, height: Float, centerX: Float, centerY: Float) {
        xShift = centerX - self.centerX
        yShift = centerY - self.centerY
        genMap(width: width, height: height)
    }

    var spaceAvailable: Bool {
        usedAreaPercentage < maxCapacity
    }

    func getRandomPosition() -> (Float, Float)? {
        if let randomPoint = availablityMap.filter({ $0.value }).randomElement() {
            usePoint(coordPairs: randomPoint.key)
            return (Float(randomPoint.key.x) * nodeDistance, Float(randomPoint.key.y) * nodeDistance)
        }
        return nil
    }
}


private extension LandmarkMap {
    var usedAreaPercentage: Float {
        Float(availablityMap.filter({ $0.value }).count) / Float(availablityMap.count)
    }

    func genMap(width: Float, height: Float) {
        genMapUpperLeft(width: width, height: height)
        genMapUpperRight(width: width, height: height)
        genMapLowerLeft(width: width, height: height)
        genMapLowerRight(width: width, height: height)
    }

    func genMapUpperLeft(width: Float, height: Float) {
        let xMax = getNumberOfPoints(distance: width - xShift)
        let yMax = getNumberOfPoints(distance: height + yShift)

        addToMap(xMin: -xMax, xMax: 0, yMin: 0, yMax: yMax)
    }

    func genMapUpperRight(width: Float, height: Float) {
        let xMax = getNumberOfPoints(distance: width + xShift)
        let yMax = getNumberOfPoints(distance: height + yShift)

        addToMap(xMin: 0, xMax: xMax, yMin: 0, yMax: yMax)
    }

    func genMapLowerLeft(width: Float, height: Float) {
        let xMax = getNumberOfPoints(distance: width - xShift)
        let yMax = getNumberOfPoints(distance: height - yShift)

        addToMap(xMin: -xMax, xMax: 0, yMin: -yMax, yMax: 0)
    }

    func genMapLowerRight(width: Float, height: Float) {
        let xMax = getNumberOfPoints(distance: width + xShift)
        let yMax = getNumberOfPoints(distance: height - yShift)

        addToMap(xMin: 0, xMax: xMax, yMin: -yMax, yMax: 0)
    }

    func addToMap (xMin: Int, xMax: Int, yMin: Int, yMax: Int) {
        for x in xMin...xMax {
            for y in yMin...yMax {
                if availablityMap.keys.contains(CoordPairs(x: x, y: y)) {
                    continue
                }
                availablityMap[CoordPairs(x: x, y: y)] = true
            }
        }
    }

    private func getNumberOfPoints(distance: Float) -> Int {
        Int(floor( distance / 2 / nodeDistance ))
    }

    private func usePoint(coordPairs: CoordPairs) {
        availablityMap[coordPairs] = false
    }

}
