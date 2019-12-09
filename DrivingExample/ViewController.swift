//
//  ViewController.swift
//  DrivingExample
//
//  Created by Juraj Antas on 21/10/2019.
//  Copyright © 2019 Sygic a.s. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelState: UILabel!

    var lastTripId : String?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        clearText()

        NotificationCenter.default.addObserver(self, selector: #selector(afterDrivingInitialization), name: .HEKDrivingInitialized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripStarted), name: .HEKTripStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripEnded), name: .HEKTripEnded, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(detectorStateChangedNotification(notification:)), name: .HEKTripDetectorStateChanged, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(eventStarted(notification:)), name: .HEKTripEventStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventUpdated(notification:)), name: .HEKTripEventUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventEnded(notification:)), name: .HEKTripEventEnded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventCanceled(notification:)), name: .HEKTripEventCanceled, object: nil)
    }

    @objc func afterDrivingInitialization() {
        //ask for permissions, use helper methos. However you are free to use your own if you need more control.
        SygicDriving.sharedInstance().requestLocationAlwaysPermission()
        SygicDriving.sharedInstance().requestMotionPermision()
        self.labelState.text = "Initialized"
    }

    func isInitialized() -> Bool {
        return SygicDriving.sharedInstance().isInitialized
    }

    func writeText(text: String) {
        self.textView.insertText(text)
    }

    func clearText() {
        self.textView.text = ""
    }

    @IBAction func onLast10Trips(_ sender: Any) {
        guard isInitialized() else {
            return
        }

        let endDate = Date()
        let startDate = Date(timeIntervalSince1970: (Date().timeIntervalSince1970 - 30*24*3600))
        SygicDriving.sharedInstance().serverApi.userTrips(withStart: startDate, end: endDate, page: 1, pageSize: 10) { (data : SygicUserTripsContainerModel?, error : Error?) in
            guard let data = data, error == nil else {
                self.writeText(text: "Error:\(String(describing: error))")
                return
            }

            let formater = DateFormatter()
            formater.dateStyle = .short
            formater.timeStyle = .short

            self.lastTripId = data.trips.first?.externalId

            if data.trips.count == 0 {
                self.writeText(text: "There are no trips. Go take a drive.\n")
                return
            }

            self.writeText(text: "Trips:\n")
            for trip in data.trips {
                let startStr = formater.string(from: trip.startDate)
                let endStr = formater.string(from: trip.endDate)
                let kmDriven = String(format: "%.2f", trip.totalDistanceInKm)
                let score = String(format: "%.0f", trip.totalScore)
                let finalText = "\(startStr) - \(endStr) \(kmDriven)km Score: \(score)\n"
                self.writeText(text: finalText)
            }
            self.writeText(text: "\n")
        }

    }

    @IBAction func onLastTripDetail(_ sender: Any) {
        guard isInitialized() else {
            self.writeText(text: "Not initialized, exiting.")
            return
        }

        guard let lastTripId = lastTripId else {
            self.writeText(text: "No tripId, exiting.")
            return
        }

        SygicDriving.sharedInstance().serverApi.tripDetail(withTripId: lastTripId) { (trip : SygicUserTripDetailModel?, error : Error?) in
            guard let trip = trip, error == nil else {
                self.writeText(text: "Error:\(String(describing: error))")
                return
            }

            let formater = DateFormatter()
            formater.dateStyle = .short
            formater.timeStyle = .short

            let startStr = formater.string(from: trip.startDate)
            let endStr = formater.string(from: trip.endDate)
            let kmDriven = String(format: "%.2f", trip.totalDistanceInKm)
            let score = String(format: "%.0f", trip.totalScore)
            let finalText = "\(startStr) - \(endStr) \(kmDriven)km Score: \(score)\n"
            self.writeText(text: finalText)
        }
    }

    @IBAction func onUserStatistics(_ sender: Any) {
        guard isInitialized() else {
            self.writeText(text: "Not initialized, exiting.")
            return
        }

        SygicDriving.sharedInstance().serverApi.liveStatsCompletionBlock { (stats : [SygicStats]?, error: Error?) in
            guard let stats = stats, error == nil else {
                self.writeText(text: "Error:\(String(describing: error))")
                return
            }

            for s in stats {
                if s.period.periodType == .total {
                    self.writeText(text: "1.Lifetime\n")
                }
                else if s.period.periodType == .last7Days {
                    self.writeText(text: "2.Last 7 days\n")
                }
                else {
                    continue
                }

                // s.tripsCount
                let totalScoreMeStr = String(format: "%.0f", s.totalScore.scoreOfMe)
                let totalScoreOthersStr = String(format: "%.0f", s.totalScore.scoreOfOthersOverall)
                let finalStr = "Number of trips:\(s.tripsCount)\nMy score:\(totalScoreMeStr)\nOthers:\(totalScoreOthersStr)\n"
                self.writeText(text: finalStr)
            }
            self.writeText(text: "\n")
        }
    }

    @IBAction func onClearLog(_ sender: Any) {
        clearText()
    }

    @IBAction func onStartTrip(_ sender: Any) {
        guard isInitialized() else {
            self.writeText(text: "Not initialized, exiting.")
            return
        }

        SygicDriving.sharedInstance().startTrip()
    }

    @IBAction func onEndTrip(_ sender: Any) {
        guard isInitialized() else {
            self.writeText(text: "Not initialized, exiting.")
            return
        }

        SygicDriving.sharedInstance().endTrip()
    }

    //MARK: notification listeners
    @objc func tripStarted() {
        self.writeText(text: "Trip started.\n")
        self.labelState.text = "Trip started"
    }

    @objc func tripEnded() {
        self.writeText(text: "Trip ended.\n")
        self.labelState.text = "Trip ended"
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

