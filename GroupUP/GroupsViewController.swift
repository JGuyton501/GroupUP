//
//  SecondViewController.swift
//  GroupUP
//
//  Created by Tony De La Nuez on 4/5/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var groups: [Group] = []
    @IBOutlet weak var tableView: UITableView!
    
    var user: FIRUser!
    private lazy var groupEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    
    
    // Attach a listener to update the view
    private func detectChannels() {
        // Listen for the children of "groups" to change
        groupEndpoint.observe(FIRDataEventType.childAdded, with: { snapshot in
            // Get the ID of the group
            let id = snapshot.key
            
            // Conveniently store data
            guard let name = snapshot.value as? String else {
                return
            }
            
            let group = Group(id: id, name: name)
            self.groups.append(group)
            self.tableView.reloadData()
        })
    }
    
    // TableView overrides
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        cell.textLabel?.text = self.groups[indexPath.item].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        self.performSegue(withIdentifier: "presentChatViewController", sender: group)
    }
    
    // Additional overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let group = sender as? Group else {
            return
        }
        
        if let vc = segue.destination as? ChatViewController {
            vc.group = group
            vc.senderDisplayName = "Test"
            vc.senderId = "1234"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        FIRAuth.auth()?.signIn(withEmail: "ericgoodman@wustl.edu", password: "ericgoodman") { (user, error) in
            self.user = user
            
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.detectChannels()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
