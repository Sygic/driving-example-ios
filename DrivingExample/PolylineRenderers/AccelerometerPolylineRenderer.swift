//
//  AccelerometerPolylineRenderer.swift
//  Hekate
//
//  Created by Juraj Antas on 10/12/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit
import MapKit

class AccelerometerPolylineRenderer: MKPolylineRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let path = self.path else {
            return
        }
        let boundingBox = path.boundingBox
        let mapRectCG = rect(for: mapRect)

        if(!mapRectCG.intersects(boundingBox)) { return }


//        var prevColor: CGColor?
//        var currentColor: CGColor?

        guard let polyline = self.polyline as? AccelerometerPolyline else { return }

        //-------- new faster but simpler rendering without gradient ----------
        var lastPoint : CGPoint?
        let rotation = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
        
        for index in 0...self.polyline.pointCount - 1 {
            let point = self.point(for: self.polyline.points()[index])
            let longitudalColor = polyline.getLongitudalHue(from: index)
            let lateralColor = polyline.getLateralHue(from: index)

            if lastPoint == nil {
                context.move(to: point)
            } else {
                if let lastPoint = lastPoint {

                    let baseWidth = (self.lineWidth) / zoomScale
                    context.setLineWidth(baseWidth)
                    context.setStrokeColor(longitudalColor)

                    context.strokeLineSegments(between: [lastPoint,point])

                    let vector = CGPoint(x: lastPoint.x - point.x, y: lastPoint.y - point.y)
                    let lateralG = polyline.getLateralG(from: index)
                    let rotatedVector = vector.applying(rotation).normalized() * lateralG*400

                    let pointRotated = CGPoint(x: lastPoint.x + rotatedVector.x, y: lastPoint.y + rotatedVector.y)
                    let baseWidth2 = (self.lineWidth) / zoomScale
                    context.setLineWidth(baseWidth2)
                    context.setStrokeColor(lateralColor)
                    context.strokeLineSegments(between: [lastPoint,pointRotated])
                    
                }
            }
            lastPoint = point

        }



        //-------- old with gradient -------------
        /*
        for index in 0...self.polyline.pointCount - 1 {
            let point = self.point(for: self.polyline.points()[index])
            let path = CGMutablePath()


            currentColor = polyLine.getHue(from: index)

            if index == 0 {
                path.move(to: point)
            } else {
                let prevPoint = self.point(for: self.polyline.points()[index - 1])
                path.move(to: prevPoint)
                path.addLine(to: point)

//                let colors = [prevColor!, currentColor!] as CFArray
                let colors = [currentColor!, currentColor!] as CFArray
                let baseWidth = (self.lineWidth+7) / zoomScale

                context.saveGState()
                context.addPath(path)

                let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1])

                context.setLineWidth(baseWidth)
                context.replacePathWithStrokedPath()
                context.clip()
                context.drawLinearGradient(gradient!, start: prevPoint, end: point, options: [])
                context.restoreGState()
            }
            prevColor = currentColor
        }
 */
    }

}
