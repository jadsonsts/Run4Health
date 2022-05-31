//
//  RunsListTableViewController.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import UIKit

class RunsListTableViewController: UITableViewController {
    
    var workouts: WorkoutsModel!
    var runs = [Runs]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if runs.count == 0 {
            return 1
        } else {
            return runs.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.workoutCellId, for: indexPath)
        let run = runs[indexPath.row]
        cell.textLabel?.text = FormatDisplay.date(run.date)
        cell.detailTextLabel?.text = "\(FormatDisplay.distance(run.distance)) | \(FormatDisplay.time(run.duration))"
        return cell
    }
    



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
