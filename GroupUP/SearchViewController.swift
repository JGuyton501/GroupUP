//
//  SearchViewController.swift
//  GroupUP
//
//  Created by Eric Goodman on 4/18/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var groups: [Group] = []
    var filteredGroups: [Group] = []
    var active = false
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("pins")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchbar.delegate = self
        self.detectGroups()
    }
    
    // Attach a listener to update the view
    private func detectGroups() {
        
        var groupDictionary : Dictionary<String, String> = [:]
        
        groupEndpoint.observe(FIRDataEventType.childAdded, with: { snap in
            if let groupInfo = snap.value as? [String:Any] {
                if let id = groupInfo["id"] as? Int, let name = groupInfo["name"] as? String {
                    let stringId = String(id)
                    let group = Group(id: stringId, name: name)
                    self.groups.append(group)
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    
    // TableView overrides
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.active ? self.filteredGroups.count : self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        if (self.active && self.searchbar.text != "") {
            cell.textLabel?.text = self.filteredGroups[indexPath.item].name
        }
        else {
            cell.textLabel?.text = self.groups[indexPath.item].name
        }
        return cell
    }
    
    // SearchBar overrides
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.active = false
        self.searchbar.text = ""
        self.searchbar.showsCancelButton = false
        self.searchbar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.active = true
        self.searchbar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredGroups = self.groups.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        self.active = self.filteredGroups.count > 0 || self.searchbar.text != ""
        self.tableView.reloadData()
    }
    
    
    
}
