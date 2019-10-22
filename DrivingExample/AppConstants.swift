//
//  AppConstants.swift
//  DrivingExample
//
//  Created by Juraj Antas on 21/10/2019.
//  Copyright © 2019 Sygic a.s. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let HEKDrivingInitialized = Notification.Name("HEKDrivingInitialized")
    static let HEKDrivingInitializationFailed = Notification.Name("HEKDrivingInitializationFailed")
    static let HEKPermissionsUpdated = Notification.Name("HEKPermissionsUpdated")
    static let HEKTripModelHasChanged = Notification.Name("HEKTripModelHasChanged")
    static let HEKTripStarted = Notification.Name("HEKTripStarted")
    static let HEKTripEnded = Notification.Name("HEKTripEnded")
    static let HEKTripReportingEvent = Notification.Name("HEKTripReportingEvent")
    static let HEKTripEventStarted = Notification.Name("HEKTripEventStarted")
    static let HEKTripEventUpdated = Notification.Name("HEKTripEventUpdate")
    static let HEKTripEventEnded = Notification.Name("HEKTripEventEnded")
    static let HEKTripEventCanceled = Notification.Name("HEKTripEventCanceled")
    static let HEKTripDetectorStateChanged = Notification.Name("HEKTripDetectorStateChanged")
    static let HEKTripDetectorCorrectionAngle = Notification.Name("HEKTripDetectorCorrectionAngle")
    static let HEKTripScoreChanged = Notification.Name("HEKTripScoreChanged")
}
