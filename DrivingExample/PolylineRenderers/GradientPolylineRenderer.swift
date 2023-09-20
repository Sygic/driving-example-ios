//
//  GradientPolylineRenderer.swift
//  Hekate
//
//  Created by Juraj Antas on 27/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit
import MapKit

class GradientPolylineRenderer: MKPolylineRenderer {
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let boundingBox = self.path.boundingBox
        let mapRectCG = rect(for: mapRect)
        
        if(!mapRectCG.intersects(boundingBox)) { return }
        
        
        var prevColor: CGColor?
        var currentColor: CGColor?
        
        guard let polyLine = self.polyline as? GradientPolyline else { return }
        
        for index in 0...self.polyline.pointCount - 1{
            let point = self.point(for: self.polyline.points()[index])
            let path = CGMutablePath()
            
            
            currentColor = polyLine.getHue(from: index)
            
            if index == 0 {
                path.move(to: point)
            } else {
                let prevPoint = self.point(for: self.polyline.points()[index - 1])
                path.move(to: prevPoint)
                path.addLine(to: point)
                
                let colors = [prevColor!, currentColor!] as CFArray
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
    }
}
