//
//  AccelerometerPolyline.swift
//  Hekate
//
//  Created by Juraj Antas on 10/12/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit
import MapKit


struct AccelerometerGPSPoint {
    var coordinate : CLLocationCoordinate2D
    var lateralG : Double
    var longitudalG : Double
}

class AccelerometerPolyline: MKPolyline {
    var huesLongitudal: [CGFloat]?
    var huesLateral: [CGFloat]?
    var lateralGs: [CGFloat]?
    var longitudalGs: [CGFloat]?

    public func getLateralG(from index: Int) -> CGFloat {
        return (lateralGs?[index])!
    }

    public func getLongitudalG(from index: Int) -> CGFloat {
        return (longitudalGs?[index])!
    }

    public func getLongitudalHue(from index: Int) -> CGColor {
        let hue = (huesLongitudal?[index])!
        let brightness : CGFloat = (hue == -1) ? 0.0 : 1.0
        return UIColor(hue: hue, saturation: 1, brightness: brightness, alpha: 1).cgColor
    }

    public func getLateralHue(from index: Int) -> CGColor {
        let hue = (huesLateral?[index])!
        let brightness : CGFloat = (hue == -1) ? 0.0 : 1.0
        return UIColor(hue: hue, saturation: 1, brightness: brightness, alpha: 1).cgColor
    }
}

extension AccelerometerPolyline {
    convenience init(locations: [AccelerometerGPSPoint]) {
        let coordinates = locations.map( { $0.coordinate } )
        self.init(coordinates: coordinates, count: coordinates.count)
        //                                                 cervena       zelena
        let valueMinLateral = -0.5, valueMaxLateral = 0.5, color1 = 0.0, color2 = 0.3
        let valueMinLongitude = -0.25, valueMaxLongitude = 0.25

        lateralGs = locations.map({
            return CGFloat($0.lateralG)
        })
        longitudalGs = locations.map({
            return CGFloat($0.longitudalG)
        })

        huesLongitudal = locations.map({
            let velocity: Double = $0.longitudalG
            let value = clamp(velocity, minValue: valueMinLongitude, maxValue: valueMaxLongitude)
            let interpolate = 1.0 - (value - valueMinLongitude) / (valueMaxLongitude - valueMinLongitude) //[0,1]
            let hue =  color1 * interpolate + (1.0 - interpolate) * color2
            return CGFloat(hue)
        })

        huesLateral = locations.map({
            let velocity: Double = $0.lateralG
            let value = clamp(velocity, minValue: valueMinLateral, maxValue: valueMaxLateral)
            let interpolate = 1.0 - (value - valueMinLateral) / (valueMaxLateral - valueMinLateral) //[0,1]
            let hue =  color1 * interpolate + (1.0 - interpolate) * color2
            return CGFloat(hue)
        })
    }
}
