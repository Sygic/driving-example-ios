//
//  GradientPolyline.swift
//  Hekate
//
//  Created by Juraj Antas on 27/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import Foundation
import MapKit

class GradientPolyline: MKPolyline {
    var hues: [CGFloat]?
    public func getHue(from index: Int) -> CGColor {
        return UIColor(hue: (hues?[index])!, saturation: 1, brightness: 1, alpha: 1).cgColor
    }
}

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
    return min(max(value, minValue), maxValue)
}

//public func interpolate<T>(_ value: T, value1: T, value2: T) -> T where T : Comparable {
//
//}

extension GradientPolyline {

    convenience init(gpsPoints: [CLLocation], accelerometerData: [Float]) {
        let coordinates = gpsPoints.map { (gpsPoint) -> CLLocationCoordinate2D in
            let c = gpsPoint.coordinate
            return c
        }
        self.init(coordinates: coordinates, count: coordinates.count)

//        let valueMax: Double = 16.0, valueMin = 0.0, color1 = 0.0, color2 = 0.3

        /*
        hues = locations.map({
            let velocity: Double = $0.speed
            if velocity < 0 {
                return CGFloat(0.8)
            }

            let value = clamp(velocity, minValue: valueMin, maxValue: valueMax)
            let interpolate = (value - valueMin) / (valueMax - valueMin) //[0,1]
            let hue =  color1 * interpolate + (1.0 - interpolate) * color2
            return CGFloat(hue)
        })
         */
    }

    convenience init(locations: [CLLocation]) {
        let coordinates = locations.map( { $0.coordinate } )
        self.init(coordinates: coordinates, count: coordinates.count)
        //                                          cervena      zelena
        let valueMax: Double = 16.0, valueMin = 0.0, color1 = 0.0, color2 = 0.3
        
        hues = locations.map({
            let velocity: Double = $0.speed
            if velocity < 0 {
                return CGFloat(0.8)
            }
            
            let value = clamp(velocity, minValue: valueMin, maxValue: valueMax)
            let interpolate = (value - valueMin) / (valueMax - valueMin) //[0,1]
            let hue =  color1 * interpolate + (1.0 - interpolate) * color2
            return CGFloat(hue)
        })
    }
}
