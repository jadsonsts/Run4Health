//
//  RunsListTableViewController.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import UIKit

class RunsListTableViewController: UITableViewController {
    
    
    var runs: [Runs]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return RunsList.instance.runs.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.workoutCellId, for: indexPath)
        let run = RunsList.instance.runs[indexPath.row]
        cell.textLabel?.text = "Run on: \(FormatDisplay.date(run.date))"
        
        if run.showInKm {
            cell.detailTextLabel?.text = "Distance: \(FormatDisplay.distanceKm(run.distance)) | Duration: \(FormatDisplay.time(run.duration))"
        } else {
            cell.detailTextLabel?.text = "Distance: \(FormatDisplay.distanceMile(run.distance)) | Duration: \(FormatDisplay.time(run.duration))"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let run = RunsList.instance.runs[indexPath.row]
        performSegue(withIdentifier: K.detailSegue, sender: run)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailsRunViewController, let run = sender as? Runs {
            destinationVC.runs = run
            destinationVC.showKm = run.showInKm
        }
    }
}
