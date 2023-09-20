//
//  AppSettings.swift
//  DrivingTestApp
//
//  Created by Juraj Antas on 20/04/2020.
//  Copyright © 2020 Juraj Antas. All rights reserved.
//

import Foundation

class AppSettings {
    static let shared = AppSettings()

    private init() {
        setupDefaultValues()
    }

    enum Keys : String {
        case developerMode
        case motionActivity
        case automaticTripStart
        case lowPowerMode
        case batteryLimit //0, 100%
        case tripMinDuration
        case tripMinDistance
        case stepIgnoreTime
    }
    
    func initializeSygicDrivingValues() {
        SygicDriving.sharedInstance().developerMode = AppSettings.shared.developerMode
        SygicDriving.sharedInstance().enableTripDetection(AppSettings.shared.automaticTripStart)
        SygicDriving.sharedInstance().disableTripDetectionInLowPowerMode = AppSettings.shared.lowPowerMode
        SygicDriving.sharedInstance().disableTripDetectionIfBatteryIsLowerThan = Double(AppSettings.shared.batteryLimit) / 100.0
        SygicDriving.sharedInstance().disableMotionActivity = AppSettings.shared.motionActivity
        SygicDriving.sharedInstance().setMinimalTripDuration(Double(AppSettings.shared.tripMinDuration), distance: Double(AppSettings.shared.tripMinDistance))
        SygicDriving.sharedInstance().setStepsIgnoreTime(Double(AppSettings.shared.stepsIgnoreTime))
    }

    func setupDefaultValues() {
        let defaultValues : [String : Any] = [
            Keys.developerMode.rawValue : true,
            Keys.automaticTripStart.rawValue : true,
            Keys.lowPowerMode.rawValue : false,
            Keys.batteryLimit.rawValue : 0,
            Keys.motionActivity.rawValue : false,
            Keys.tripMinDuration.rawValue : 90,
            Keys.tripMinDistance.rawValue : 300,
            Keys.stepIgnoreTime.rawValue : 0
        ]
        UserDefaults.standard.register(defaults: defaultValues)
    }

    var developerMode : Bool {
        set  {
            UserDefaults.standard.set(newValue, forKey: Keys.developerMode.rawValue)
        }
        get {
            let value = UserDefaults.standard.bool(forKey: Keys.developerMode.rawValue)
            return value
        }
    }
    
    var motionActivity : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.motionActivity.rawValue)
        }
        
        get {
            let value = UserDefaults.standard.bool(forKey: Keys.motionActivity.rawValue)
            return value
        }
    }

    var automaticTripStart : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.automaticTripStart.rawValue)
        }

        get {
            let value = UserDefaults.standard.bool(forKey: Keys.automaticTripStart.rawValue)
            return value
        }
    }
    
    var lowPowerMode : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lowPowerMode.rawValue)
        }
        
        get {
            let value = UserDefaults.standard.bool(forKey: Keys.lowPowerMode.rawValue)
            return value
        }
    }
    
    var batteryLimit : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.batteryLimit.rawValue)
        }
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.batteryLimit.rawValue)
            return value
        }
    }
    
    //seconds
    var tripMinDuration : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.tripMinDuration.rawValue)
        }
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.tripMinDuration.rawValue)
            return value
        }
    }
    //meters
    var tripMinDistance : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.tripMinDistance.rawValue)
        }
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.tripMinDistance.rawValue)
            return value
        }
    }

    //seconds
    var stepsIgnoreTime : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.stepIgnoreTime.rawValue)
        }
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.stepIgnoreTime.rawValue)
            return value
        }
    }

}
