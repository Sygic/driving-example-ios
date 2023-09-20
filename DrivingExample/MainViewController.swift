//
//  ViewController.swift
//  DrivingExample
//
//  Created by Juraj Antas on 21/10/2019.
//  Copyright © 2019 Sygic a.s. All rights reserved.
//

import UIKit
import Driving

class MainViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelState: UILabel!

    var lastTripId : String?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        clearText()

        NotificationCenter.default.addObserver(self, selector: #selector(tripStarted), name: .HEKTripStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripEnded), name: .HEKTripEnded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripStartCanceled), name: .HEKTripStartCancelled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripDiscarted), name: .HEKTripDiscarted, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(detectorStateChangedNotification(notification:)), name: .HEKTripDetectorStateChanged, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(eventStarted(notification:)), name: .HEKTripEventStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventUpdated(notification:)), name: .HEKTripEventUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventEnded(notification:)), name: .HEKTripEventEnded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventCanceled(notification:)), name: .HEKTripEventCanceled, object: nil)
        
        
        afterDrivingInitialization()
    }

    @objc func afterDrivingInitialization() {
        //ask for permissions, use helper methos. However you are free to use your own if you need more control.
        SygicDriving.sharedInstance().requestLocationAlwaysPermission()
        SygicDriving.sharedInstance().requestMotionPermision()
        //for development purposes it is good to have level set at .debug
        //but never ship it. Set it to .error for production builds
        SygicDriving.sharedInstance().setLogLevel(.debug)
        self.labelState.text = "Initialized"
    }


    func writeText(text: String) {
        self.textView.insertText(text)
    }

    func clearText() {
        self.textView.text = ""
    }

    
    @IBAction func onClearLog(_ sender: Any) {
        clearText()
    }

    @IBAction func onStartTrip(_ sender: Any) {
        SygicDriving.sharedInstance().startTrip()
    }

    @IBAction func onEndTrip(_ sender: Any) {
        SygicDriving.sharedInstance().endTrip()
    }

    //MARK: notification listeners
    @objc func tripStarted() {
        self.writeText(text: "Trip started.\n")
        self.labelState.text = "Trip started"
    }
    
    @objc func tripStartCanceled() {
        self.writeText(text: "Trip start cancelled.\n")
        self.labelState.text = "Trip start cancelled"
    }

    @objc func tripEnded() {
        self.writeText(text: "Trip ended.\n")
        self.labelState.text = "Trip ended"
    }
    
    @objc func tripDiscarted() {
        self.writeText(text: "Trip discarted.\n")
        self.labelState.text = "Trip discarted"
    }

    @objc func detectorStateChangedNotification(notification: Notification) {
        
    }

    @objc func eventStarted(notification: Notification) {
        let eventObj = notification.object as? SygicTripEvent
        guard let event = eventObj else {
            return
        }
        self.writeText(text: "Event:\(event.eventId) started\n")
    }

    @objc func eventUpdated(notification: Notification) {
        let eventObj = notification.object as? SygicTripEvent
        guard let event = eventObj else {
            return
        }
        self.writeText(text: "Event:\(event.eventId) updated Value:\(event.eventCurrentSize)\n")

    }

    @objc func eventEnded(notification: Notification) {
        let eventObj = notification.object as? SygicTripEvent
        guard let event = eventObj else {
            return
        }
        self.writeText(text: "Event:\(event.eventId) ended\n")
    }

    @objc func eventCanceled(notification: Notification) {
        let eventObj = notification.object as? SygicTripEvent
        guard let event = eventObj else {
            return
        }
        self.writeText(text: "Event:\(event.eventId) canceled\n")
    }

}

