//
//  TripListCell.swift
//  Hekate
//
//  Created by Juraj Antas on 22/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit

class TripListCell: UITableViewCell {

    @IBOutlet weak var labelTripDates: UILabel!
    @IBOutlet weak var labelTripDuration: UILabel!
    @IBOutlet weak var labelReasons: UILabel!
    @IBOutlet weak var labelUploadInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWith(startDate: Date, endDate: Date, startReason: SygicTripStartReason, endReason: SygicTripEndReason, uploadDate: Date?, tripId : String?, httpCode: Int, retryCount: Int) {
        let startDateStr = DateFormatter.myTripFormat().string(from: startDate)
        let endDateStr = DateFormatter.myTripFormat().string(from: endDate)
        if let uploadDate = uploadDate {
            let uploadDateStr = DateFormatter.myTripFormat().string(from: uploadDate)
            
            let str = "\(uploadDateStr) id:\(tripId ?? "-")\n httpCode:\(httpCode) retry:\(retryCount)"
            self.labelUploadInfo.text = str
        }
        else {
            self.labelUploadInfo.text = ""
        }
        

        labelTripDates.text = "\(startDateStr)\n\(endDateStr)"
        let startReasonText : String
        switch startReason {
        case .unknown:
            startReasonText = "unknown"
        case .gps:
            startReasonText = "gps"
        case .manual:
            startReasonText = "manual"
        case .motionActivity:
            startReasonText = "MA"
        default:
            startReasonText = "unknown"
        }

        let endReasonText : String
        switch endReason {
        case .unknown:
            endReasonText = "unknown"
        case .gpsGap:
            endReasonText = "gps gap"
        case .manual:
            endReasonText = "manual"
        case .maxTripDuration:
            endReasonText = "max trip duration"
        case .motionActivity:
            endReasonText = "MA"
        case .steps:
            endReasonText = "steps"
        case .timeoutNotMoving:
            endReasonText = "timeout not moving"
        default:
            endReasonText = "unknown"
        }
        labelReasons.text = "\(startReasonText)\n\(endReasonText)"

        let dateIntervalFormatter = DateIntervalFormatter()
        dateIntervalFormatter.dateStyle = .none
        dateIntervalFormatter.timeStyle = .medium

        let diff = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let hours = floor(diff / 3600.0)
        let minutes = floor((diff - (hours * 3600.0))/60.0)
        let seconds = round(diff - ((hours * 3600.0)+(minutes*60)))
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .abbreviated
        var components = DateComponents()

        components.hour = Int(hours)
        components.minute = Int(minutes)
        components.second = Int(seconds)
        let str = componentsFormatter.string(from: components)

        labelTripDuration.text = str
        
        
    }

}
