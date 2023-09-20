//
//  CGpoint+extension.swift
//  Hekate
//
//  Created by Juraj Antas on 12/12/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    public func lengthSquared() -> CGFloat {
        return x*x + y*y
    }
    func normalized() -> CGPoint {
        let len = length()
        return len>0 ? self / len : CGPoint.zero
    }
    public mutating func normalize() -> CGPoint {
        self = normalized()
        return self
    }
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static public func - (left: CGPoint, right: CGVector) -> CGPoint {
        return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
    }
    static public func / (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
    static public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
    static public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
}

