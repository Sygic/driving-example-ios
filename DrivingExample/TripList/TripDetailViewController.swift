//
//  TripDetailViewController.swift
//  Hekate
//
//  Created by Juraj Antas on 23/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit
import MapKit
import simd
import MessageUI


class Polyline : MKPolyline {
    var color : UIColor?
    var dashed : Bool = false
}

class Circle : MKCircle {
    var color : UIColor?
}

class MyAnnotations : MKPointAnnotation {
    var pinColor : UIColor?
}



class TripDetailViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate{
    var tripData : SygicDrivingTrip?
    var tripIndex : Int?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelScores: UILabel!

    var tripAccData : [SIMD3<Double>]  = []
    var tripEvents : [SygicTripEvent] = []

    var polylineOverlays : [GradientPolyline] = []
    var polyline : [Polyline] = []
    var accelPolylines : [AccelerometerPolyline] = []
    var circles : [Circle] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tripData = self.tripData else {
            return
        }

        updateReplayButtons()

        let events : [SygicTripEvent] = tripData.tripEvents.sorted { (e1, e2) -> Bool in
            return e1.eventTimestamp > e2.eventTimestamp
        }

        var numA = 0
        var numB = 0
        var numC = 0
        var numD = 0
        var numH = 0
        var numS = 0

        for event in events {
            switch event.eventType {
            case .acceleration:
                numA+=1
            case .braking:
                numB+=1
            case .cornering:
                numC+=1
            case .distraction:
                numD+=1
            case .speeding:
                numS+=1
            case .unknown:
                numH+=1
            default:
                break
            }

        }

        self.labelScores.text = "A:\(numA)  B:\(numB)  C:\(numC)  D:\(numD)  H:\(numH) S:\(numS)"

        for segment in tripData.tripSegments {
            drawSpeedPolylineOnMap(gpsPositions: segment.tripGpsPositions, segment: segment)
        }
        
        addTrackAnnotationsForEvents(events: tripData.tripEvents)

        //zoom on track
        var coordinates: [CLLocationCoordinate2D] = []
        for segment in tripData.tripSegments {
            for point in segment.tripGpsPositions {
                coordinates.append(point.coordinate)
            }
        }
        
        if let p1 = coordinates.first, let p2 = coordinates.last {
            drawStartStop(startPoint: p1, endPoint: p2)
        }
        
        
    
        let rects = coordinates.map { MKMapRect(origin: MKMapPoint($0), size: MKMapSize()) }
        let fittingRect = rects.reduce(MKMapRect.null) { $0.union($1) }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 100000000)) {
            self.mapView.setVisibleMapRect(fittingRect, edgePadding: UIEdgeInsets(top: 100, left: 10, bottom: 100, right: 10), animated: false)
        }

    }
    
    func updateReplayButtons() {
        let simulateButton = UIBarButtonItem(title: "Replay", style: .plain, target: self, action: #selector(startReplay))

        if SygicDriving.sharedInstance().isReplayRunning() {
            let replaybutton = UIBarButtonItem(title: "Stop Replay", style: .plain, target: self, action: #selector(stopReplay))
            self.navigationItem.rightBarButtonItems = [replaybutton]
        }
        else {
            if tripIndex != nil {
                self.navigationItem.rightBarButtonItems = [simulateButton]
            }
        }
    }

    @objc func stopReplay() {
        SygicDriving.sharedInstance().stopReplay()
        updateReplayButtons()
    }

    @objc func startReplay() {
        if let index = tripIndex {
            SygicDriving.sharedInstance().replayTrip(at: index)
            updateReplayButtons()
        }
    }
    
    @objc func startSim() {
        if let index = tripIndex {
            let vehicleSettings = SygicVehicleSettings()
            vehicleSettings.vehicleType = .truck
            vehicleSettings.vehicleTrailers = 0
            vehicleSettings.vehicleHazmat = false
            vehicleSettings.vehicleMaxSpeed = 90
            vehicleSettings.vehicleFuelType = .diesel
            vehicleSettings.vehicleWeight = 10000
            vehicleSettings.vehicleLength = 5434
            vehicleSettings.vehicleAxles = 2
            //vehicleSettings.vehicleId = "Some vehicle id" //if server receives vehicle id that is unknown we get back 422
            
            SygicDriving.sharedInstance().simulateWithTrip(at: index, vehicleSettings: vehicleSettings)
        }
    }

    

    func addTrackAnnotationsForEvents(events: [SygicTripEvent]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.timeZone = TimeZone.current

        for event in events {
            guard let point = event.eventPosition else {
                continue;
            }

            let coordinate = CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
            let annotation = MyAnnotations()

            

            let eventTypeString = convertTripEventToString(eventType: event.eventType)
            let timeString = formatter.string(from: event.eventDate)
            annotation.title = eventTypeString + " " + timeString
            let angle =  event.eventAngle > 998 ? "-" : String(format:"%.2f",radiansToDegrees(radians:event.eventAngle))
            if event.eventType == .carCrash {
                annotation.subtitle = "Duration:\(String(format: "%.2f",event.eventLength))sec, Energy:\(String(format:"%.2f",event.eventMaxSize)) sd:\(String(format:"%.2f",event.eventCurrentSize))"
            }
            else {
                annotation.subtitle = "\(String(format: "%.2f",event.eventLength))sec, Max:\(String(format:"%.2f",event.eventMaxSize)) ∅:\(String(format:"%.2f",event.eventMeanSize)) 𝛂:\(angle)"
            }
            
            
            annotation.coordinate = coordinate
            switch event.eventType {
            case .distraction:
                annotation.pinColor = UIColor.purple
            case .acceleration:
                annotation.pinColor = UIColor.red
            case .braking:
                annotation.pinColor = UIColor.green
            case .cornering:
                annotation.pinColor = UIColor.blue
            case .speeding:
                annotation.pinColor = UIColor.yellow
            case .unknown:
                annotation.pinColor = UIColor.black
            case .holeInSensorData:
                annotation.pinColor = UIColor.brown
            case .carCrash:
                annotation.pinColor = UIColor.cyan
            default:
                annotation.pinColor = UIColor.white
            }

            mapView.addAnnotation(annotation)
        }
    }

    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }

    //v normalnej apke by si toto pichol do extensny
    func convertTripEventToString(eventType : SygicTripEventType) -> String {
        switch eventType {
        case .acceleration:
            return "acceleration"
        case .braking:
            return "braking"
        case .cornering:
            return "cornering"
        case .distraction:
            return "distraction"
        case .speeding:
            return "speeding"
        case .pothole:
            return "pothole"
        case .unknown:
            return "unknown"
        case .carCrash:
            return "crash"
        case .holeInSensorData:
            return "hole in sensor data"
        case .tailgating:
            return "tailgating"
        case .traffic:
            return "traffic"
        default:
            return "totaly unknown"
        }
    }


    func drawStartStop(startPoint: CLLocationCoordinate2D, endPoint : CLLocationCoordinate2D ) {
        let startCircle = Circle(center: startPoint, radius: 20)
        startCircle.color = UIColor.green
        mapView.addOverlay(startCircle)

        let endCircle = Circle(center: endPoint, radius: 20)
        endCircle.color = UIColor.red
        mapView.addOverlay(endCircle)
    }


    func drawSpeedPolylineOnMap(gpsPositions: [CLLocation], segment : SygicDrivingTripSegment) {
        var points : [CLLocationCoordinate2D] = []

        for position in gpsPositions {

            let coordinate = position.coordinate
            points.append(coordinate);
        }
        let line = Polyline(coordinates: points, count: points.count)
        if segment.segmentType == .drive {
            line.color = .red
        }
        else if segment.segmentType == .walk {
            line.color = .blue
        }

        mapView.addOverlay(line)
        polyline.append(line)
    }


    func interpolateGpsPoint(point: CLLocation, lastPoint: CLLocation, timestamp: TimeInterval) -> CLLocation {
        let t = (timestamp - lastPoint.timestamp.timeIntervalSince1970)/(point.timestamp.timeIntervalSince1970 - lastPoint.timestamp.timeIntervalSince1970)
        //now compute coordinate that is somewhere in the middle of point and lastPoint using t
        let coordinate1 = lastPoint.coordinate
        let coordinate2 = point.coordinate

        let middleLatitude = coordinate1.latitude + t * (coordinate2.latitude - coordinate1.latitude)
        let middleLongitude = coordinate1.longitude + t * (coordinate2.longitude - coordinate1.longitude)

        let gpsPos = CLLocation(coordinate: CLLocationCoordinate2DMake(middleLatitude, middleLongitude), altitude: lastPoint.altitude, horizontalAccuracy: lastPoint.horizontalAccuracy, verticalAccuracy: lastPoint.verticalAccuracy, course: lastPoint.course, speed: lastPoint.speed, timestamp: Date(timeIntervalSince1970: timestamp))

        return gpsPos
    }


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is GradientPolyline {
            let polyLineRender = GradientPolylineRenderer(overlay: overlay)
            polyLineRender.lineWidth = 7
            return polyLineRender
        }
        else if let polyline = overlay as? Polyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = polyline.color ?? UIColor.red
            renderer.lineWidth = 3.0
            return renderer
        }
        else if let polyline = overlay as? AccelerometerPolyline {
            let renderer = AccelerometerPolylineRenderer(overlay: polyline)
            renderer.lineWidth = 7
            return renderer
        }
        else if let circle = overlay as? Circle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor =  circle.color?.withAlphaComponent(0.05) ?? UIColor.red.withAlphaComponent(0.05)
            renderer.strokeColor = circle.color ?? UIColor.red
            renderer.lineWidth = 5.0
            return renderer
        } else {
            return MKCircleRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        if let annotation = annotation as? MyAnnotations {
            let pinAnnotation = annotationView as! MKPinAnnotationView
            pinAnnotation.pinTintColor = annotation.pinColor
        }

        return annotationView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    
    
    
}
