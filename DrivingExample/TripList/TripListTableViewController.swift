//
//  TripListTableViewController.swift
//  Hekate
//
//  Created by Juraj Antas on 22/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit

class TripListTableViewController: UITableViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(modelHasChanged), name: .HEKTripModelHasChanged, object: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    @objc func modelHasChanged() {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  SygicDriving.sharedInstance().tripCount() //TripListModel.shared.numOfTrips()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripsListCell", for: indexPath) as! TripListCell
        let tripData = SygicDriving.sharedInstance().tripMeta(at: indexPath.row)
        if let tripData = tripData {
            cell.configureWith(startDate: tripData.tripStartDate, endDate: tripData.tripEndDate, startReason: tripData.tripStartReason, endReason: tripData.tripEndReason, uploadDate: tripData.tripLastUploadDate, tripId: tripData.tripServerId, httpCode: tripData.tripUploadHttpErrorCode, retryCount: tripData.tripUploadRetryCount)
        }
        return cell
    }



    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TripListModel.shared.remove(at: indexPath.row)
            SygicDriving.sharedInstance().removeTrip(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    //to disable selection on not finalized trip
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //_ = SygicDriving.sharedInstance().trip(at: indexPath.row)
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //_ = SygicDriving.sharedInstance().trip(at: indexPath.row)

        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76;
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripDetailViewController {
            let tripIndex = (tableView!.indexPathForSelectedRow?.row)!
            let tripData = SygicDriving.sharedInstance().trip(at: tripIndex)
            vc.tripData = tripData
            vc.tripIndex = tripIndex
        }

    }


}
