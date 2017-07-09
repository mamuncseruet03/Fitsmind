//
//  ViewController.swift
//  Fitsmind
//
//  Created by Mamun Ar Rashid on 7/9/17.
//  Copyright © 2017 Fantasy Apps. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UISearchBarDelegate, SaveNotifiable {

    //MARK: Properties
    
    var tasks: Results<Task>?
    @IBOutlet weak var taskListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var isAscending: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        taskListTableView.delegate = self
        taskListTableView.dataSource = self
        loadFromRealmDatabase()
        taskListTableView.cellLayoutMarginsFollowReadableWidth = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    
    private func loadFromRealmDatabase() {

        tasks =  realm.objects(Task.self)
        self.taskListTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "addNewTask":
            if let taskControllerNav = segue.destination as? UINavigationController,let taskController = taskControllerNav.viewControllers.first as? SingleTaskViewController  {
                taskController.delegate = self
            }
        case "TaskDetail":
            if let taskControllerNav = segue.destination as? UINavigationController,let taskController = taskControllerNav.viewControllers.first as? SingleTaskViewController , let row = taskListTableView.indexPathForSelectedRow?.row, let tasks = tasks  {
                taskController.delegate = self
                taskController.task = tasks[row]
            }
            
        default:
               break
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadFromRealmDatabase()
    }
    
    @IBAction func sortByDate(_ sender: UIBarButtonItem) {
        
        if let searchText = searchBar.text , !searchText.isEmpty {
            
            let predicate = NSPredicate(format:"name contains[c] %@",searchText)
            tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "date",ascending:isAscending)
        } else {
            tasks =  realm.objects(Task.self).sorted(byKeyPath: "date", ascending: isAscending)
        }
        
        self.taskListTableView.reloadData()
        
        isAscending = !isAscending
    
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
        //            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        //        })
        
        if !searchText.isEmpty {
        let predicate = NSPredicate(format:"name contains[c] %@",searchText)
        tasks = realm.objects(Task.self).filter(predicate)
        }
        
        self.taskListTableView.reloadData()
    }
    
    func successfullySaved() {
      loadFromRealmDatabase()
      //self.taskListTableView.reloadData()
    }

}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks == nil ? 0 : tasks!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        if let tasks = tasks, tasks.count >= indexPath.row {
        let task = tasks[indexPath.row]
            
        cell.nameLabel.text = task.name
        cell.nameLabel.textColor = UIColor.black
         
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.dateLabel.text = dateFormatter.string(from: task.date)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let tasks = tasks {
            try! realm.write {
                let deletedTask = tasks[indexPath.row]
                realm.delete(deletedTask)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins))  {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins))  {
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
    }

}


