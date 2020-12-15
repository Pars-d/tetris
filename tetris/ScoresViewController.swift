//
//  ScoresViewController.swift
//  EID: wl8779
//  Course: CS371L
//
//  Created by user174376 on 7/10/20.
//  Copyright © 2020 top. All rights reserved.
//

import UIKit
import CoreData

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totScores: UILabel!
    var scores: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Score")
        do {
            scores = try context.fetch(request)
        } catch {
            print("Fetch failed.")
        }
        
        totScores.text = "Total Scores: \(scores.count)"
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let score = scores[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yy HH:mm"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = UIFont(name: "ArialMT", size: 23)
        cell.textLabel?.text = """
        Score: \(score.value(forKey: "score")!)
        Lines Cleared: \(score.value(forKey: "lines")!)
        Date: \(df.string(for: score.value(forKey: "date")!)!)
        """
        
        return cell
    }

   

}
