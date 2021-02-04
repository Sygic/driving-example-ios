//
//  AppDelegate.swift
//  DrivingExample
//
//  Created by Juraj Antas on 21/10/2019.
//  Copyright © 2019 Sygic a.s. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SygicDrivingDelegate, SygicPositioningDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        application.isIdleTimerDisabled = true
        let options : UNAuthorizationOptions = [.sound, .alert]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (result, error) in
            if let _ = error {
                os_log("error requesting local notifications.")
            }
        }

        let configuration = SygicDrivingConfiguration()
        configuration.disableGeofences = false
        configuration.dontUploadTrips = false
        configuration.sendDataInRoaming = false
        configuration.sendDataOnMobile = true

        let vehicleSettings = SygicVehicleSettings()
        vehicleSettings.vehicleType = .car
        vehicleSettings.vehicleTrailers = 0
        vehicleSettings.vehicleHazmat = false
        vehicleSettings.vehicleMaxSpeed = 250
        vehicleSettings.vehicleFuelType = .diesel
        vehicleSettings.vehicleWeight = 1300
        vehicleSettings.vehicleLength = 5434
        vehicleSettings.vehicleAxles = 2

        //generate unique id, store it in user defaults, and use it when needed.
        //Ideally you get userID from your own user identification system.
        var userUUID = UserDefaults.standard.string(forKey: "appUserUUID")

        if userUUID == nil {
            //generate uuid
            let uuidString = UUID().uuidString
            UserDefaults.standard.setValue(uuidString, forKey: "appUserUUID")
            userUUID = uuidString
        }

        guard let userID = userUUID else {
            print("there is no user id, not possible. check the code above.")
            return true
        }

        print("UserId: \(userID)")

        #warning ("Here insert your client id you got from Sygic.")
        SygicDriving.sharedInstance().initialize(withClientId: "xxx.xxxx.xxxxxxxxxxx", userId: userID, configuration: configuration, vehicleSettings: vehicleSettings, countryIso: nil, noGyroMode: false) { (error) in
            if let error = error {
                print("\(error.localizedDescription)")
                NotificationCenter.default.post(name: .HEKDrivingInitializationFailed, object: nil, userInfo: nil)
            } else {
                SygicDriving.sharedInstance().delegate = self
                SygicDriving.sharedInstance().enableTripDetection(true)
                NotificationCenter.default.post(name: .HEKDrivingInitialized, object: nil, userInfo: nil)
            }
        }

        #warning("did you copied Driving.framework into Frameworks directory?")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //MARK: - Driving delegates
    func driving(_ driving: SygicDriving, tripDidStart timestamp: Double) {
        let date = Date(timeIntervalSince1970: timestamp)
        fireNotification(withText: "### Trip started ###", date: date)
        NotificationCenter.default.post(name: .HEKTripStarted, object: date)
        print("trip started")
    }

    func driving(_ driving: SygicDriving, tripDidEnd timestamp: Double) {
        let date = Date(timeIntervalSince1970: timestamp)
        fireNotification(withText: "*** Trip ended ***", date: date)
        NotificationCenter.default.post(name: .HEKTripEnded, object: date)
        print("trip ended")
    }

    //if you want to have location in start and end trip events use this delegate
    //Note: at the time when trip starts we may not have location, for example in tunnel
    func driving(_ driving: SygicDriving, tripDidStart timestamp: Double, location: CLLocation?) {
        print("trip start with location:\(String(describing: location))")
    }

    func driving(_ driving: SygicDriving, tripDidEnd timestamp: Double, location: CLLocation?) {
        print("trip end with location:\(String(describing: location))")
    }

    func driving(_ driving: SygicDriving, reporting event: SygicTripEvent) {
        print("reporting event with type: \(event.eventType.rawValue)")
    }

    func driving(_ driving: SygicDriving, eventStarted event: SygicTripEvent) {
        NotificationCenter.default.post(name: .HEKTripEventStarted, object: event)
        print("event started \(event.eventType.rawValue)")
    }

    func driving(_ driving: SygicDriving, eventUpdate event: SygicTripEvent) {
        NotificationCenter.default.post(name: .HEKTripEventUpdated, object: event)
        //        print("event update")
    }

    func driving(_ driving: SygicDriving, eventCanceled event: SygicTripEvent) {
        NotificationCenter.default.post(name: .HEKTripEventCanceled, object: event)
        print("event ended")
    }

    func driving(_ driving: SygicDriving, eventEnded event: SygicTripEvent) {
        NotificationCenter.default.post(name: .HEKTripEventEnded, object: event)
        print("event ended")
    }

    func driving(_ driving: SygicDriving, detectorStateChanged state: SygicDetectorState) {
        let number = NSNumber(value: state.rawValue)
        NotificationCenter.default.post(name: .HEKTripDetectorStateChanged, object: number)
        print("detector state changed \(state.rawValue)")
    }

    func driving(_ driving: SygicDriving, detectorDirectionAngle radians: Double) {
        let number = NSNumber(value: radians)
        NotificationCenter.default.post(name: .HEKTripDetectorCorrectionAngle, object: number)
        print("we have an angle in radians: \(radians)")
    }

    func permissionsUpdated() {
        NotificationCenter.default.post(name: .HEKPermissionsUpdated, object: nil)
        print("permissions updated")
    }

    func tripModelHasChanged() {
        NotificationCenter.default.post(name: .HEKTripModelHasChanged, object: nil)
        print("trip model has changed")
    }

    func driving(_ driving: SygicDriving, finalTripData trip: SygicDrivingTrip) {
        print("here are trip data")
    }

    // MARK: - Positionion
    //During the trip, here are reported locations with navigation accuracy
    //When trip is not running, this may report position with less accuracy and less often to preserve battery life.
    func driving(_ driving: SygicDriving, location: CLLocation) {
        print("location: \(location)")
    }

    // MARK: - Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }

    func fireNotification(withText text: String, date: Date) {
        let dateFormatter = DateFormatter()

        let content = UNMutableNotificationContent()
        content.title = text
        content.body = dateFormatter.string(from: date)
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0,
                                                        repeats: false)
        let identifier = content.body + text
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("\(error)")
            }
        })
    }


}

