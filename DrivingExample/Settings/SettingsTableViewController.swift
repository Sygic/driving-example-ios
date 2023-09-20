//
//  SettingsTableViewController.swift
//  DrivingTestApp
//
//  Created by Juraj Antas on 07/02/2020.
//  Copyright © 2020 Juraj Antas. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var switchMotionActivity: UISwitch!
    
    @IBOutlet weak var switchAutomaticTripDetection: UISwitch!
    @IBOutlet weak var switchDeveloperMode: UISwitch!
    
    @IBOutlet weak var labelUserId: UILabel!
    
    
    @IBOutlet weak var switchLowPower: UISwitch!
    
    @IBOutlet weak var labelBatteryLimit: UILabel!
    @IBOutlet weak var stepperBatteryLimit: UIStepper!
    
    @IBOutlet weak var labelTripMinDuration: UILabel!
    @IBOutlet weak var stepperTripMinDuration: UIStepper!
    
    @IBOutlet weak var labelTripMinDistance: UILabel!
    @IBOutlet weak var stepperTripMinDistance: UIStepper!
    
    @IBOutlet weak var labelStepIgnoreTime: UILabel!
    @IBOutlet weak var stepperStepIgnoreTime: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func initialSetup() {

        let enabled = SygicDriving.sharedInstance().isTripDetectionEnabled()
        self.switchAutomaticTripDetection.setOn(enabled, animated: false)
        
        let developerMode = SygicDriving.sharedInstance().developerMode;
        self.switchDeveloperMode.setOn(developerMode, animated: false)
        
        let ma = SygicDriving.sharedInstance().disableMotionActivity ? false : true
        self.switchMotionActivity.setOn(ma, animated: false)
        
        
        
        self.switchLowPower.setOn(AppSettings.shared.lowPowerMode, animated: false)
        self.labelBatteryLimit.text = String(format:"%.0f %", AppSettings.shared.batteryLimit)
        
        if let userId = UserDefaults.standard.string(forKey: "appUserUUID") {
            self.labelUserId.text = userId
        }
        else {
            self.labelUserId.text = "no user id? huh."
        }
        
        self.stepperBatteryLimit.autorepeat = true
        self.stepperBatteryLimit.maximumValue = 100
        self.stepperBatteryLimit.minimumValue = 0
        self.stepperBatteryLimit.stepValue = 1
        self.stepperBatteryLimit.value = Double(AppSettings.shared.batteryLimit)
        self.labelBatteryLimit.text = String(format: "%.0f %", Double(AppSettings.shared.batteryLimit))
        
        self.stepperTripMinDistance.autorepeat = true
        self.stepperTripMinDistance.maximumValue = 3000
        self.stepperTripMinDistance.minimumValue = 0
        self.stepperTripMinDistance.value = Double(AppSettings.shared.tripMinDistance)
        self.labelTripMinDistance.text = String(format: "%ld m", AppSettings.shared.tripMinDistance)
        
        self.stepperTripMinDuration.autorepeat = true
        self.stepperTripMinDuration.maximumValue = 600
        self.stepperTripMinDuration.minimumValue = 0
        self.stepperTripMinDuration.value = Double(AppSettings.shared.tripMinDuration)
        self.labelTripMinDuration.text = String(format: "%ld sec", AppSettings.shared.tripMinDuration)
        self.stepperStepIgnoreTime.maximumValue = 600
        self.stepperStepIgnoreTime.minimumValue = 0
        self.stepperStepIgnoreTime.value = Double(AppSettings.shared.stepsIgnoreTime)
        self.labelStepIgnoreTime.text = String (format: "%ld sec", AppSettings.shared.stepsIgnoreTime)
    }
    
    
    @IBAction func onAutomaticTripDetectionChanged(_ sender: UISwitch) {
        SygicDriving.sharedInstance().enableTripDetection(sender.isOn)
        AppSettings.shared.automaticTripStart = sender.isOn
    }

    @IBAction func onDeveloperModeChanged(_ sender: UISwitch) {
        SygicDriving.sharedInstance().developerMode = sender.isOn
        AppSettings.shared.developerMode = sender.isOn
    }
    
    
    @IBAction func onMotionActivity(_ sender: UISwitch) {
        let v = sender.isOn ? false : true
        SygicDriving.sharedInstance().disableMotionActivity = v
        AppSettings.shared.motionActivity = v
    }
    
    @IBAction func onCopyUserId(_ sender: Any) {
        if let s = UserDefaults.standard.string(forKey: "appUserUUID") {
            UIPasteboard.general.string = s
        }
    }
    
    @IBAction func onLowPowerChanged(_ sender: UISwitch) {
        AppSettings.shared.lowPowerMode = sender.isOn
        SygicDriving.sharedInstance().disableTripDetectionInLowPowerMode = sender.isOn
    }
    
    @IBAction func onBatteryLevelLimitChanged(_ sender: UIStepper) {
        let value = sender.value
        self.labelBatteryLimit.text = String(format: "%.0f %", value)
        AppSettings.shared.batteryLimit = Int(value)
        SygicDriving.sharedInstance().disableTripDetectionIfBatteryIsLowerThan = value/100.0
    }
    
    @IBAction func onMinDurationChanged(_ sender: UIStepper) {
        let value = sender.value
        self.labelTripMinDuration.text = String(format: "%.0f sec", value)
        AppSettings.shared.tripMinDuration = (Int)(value)
        SygicDriving.sharedInstance().setMinimalTripDuration(Double(AppSettings.shared.tripMinDuration), distance: Double(AppSettings.shared.tripMinDistance))
    }
    
    @IBAction func onMinDistanceChanged(_ sender: UIStepper) {
        let value = sender.value
        self.labelTripMinDistance.text = String(format: "%.0f m", value)
        AppSettings.shared.tripMinDistance = Int(value)
        SygicDriving.sharedInstance().setMinimalTripDuration(Double(AppSettings.shared.tripMinDuration), distance: Double(AppSettings.shared.tripMinDistance))
    }
    
    
    @IBAction func onStepsIgnoreTimeChanged(_ sender: UIStepper) {
        let value = sender.value
        self.labelStepIgnoreTime.text = String(format: "%.0f sec", value)
        AppSettings.shared.stepsIgnoreTime = Int(value)
        
        SygicDriving.sharedInstance().setStepsIgnoreTime(value)
    }
}
