//
//  ViewController.swift
//  sendjoy-IOS
//
//  Created by Christian Harrison on 27/02/2023.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //TODO: sort out MVC cos this is a mess!
    let request = Requests()
    var messagesData:JSON=[]
    

    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Message Confirmation"
        myTable.dataSource = self
        myTable.delegate = self
        
        fetchDataAndUpdateTableView()
        
        //Sets up refreshControl for myTable tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshVC), for: .valueChanged)
        myTable.refreshControl = refreshControl
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        fetchDataAndUpdateTableView()
    }
    
    
    @objc func refreshVC(refreshControl: UIRefreshControl) {
        //Refreshes the tableView on pull down.
        self.fetchDataAndUpdateTableView()
        refreshControl.endRefreshing()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        let rowData = messagesData[indexPath.row]
        print(messagesData)
        cell.messageTextView.text = rowData["message"].string
        cell.ipLabel.text = rowData["ipAddress"].string
        cell.phoneNumberLabel.text = rowData["phoneNumber"]["e164"].string
        if let sentiment = rowData["sentiment"].int {
            cell.sentimentLabel.text = "s: " + String(sentiment)
        } else {
            cell.sentimentLabel.text = "s: na"
        }
       
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.systemGray
                // Change the color to the desired one
            }
        let messageId = messagesData[indexPath.row]["_id"].string ?? "null"
        showAlertGeneral(messageId: messageId)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.clear
            
        }
    }
    
    
    func showAlertGeneral(messageId: String) {
        //Opens actionsheet after selecting tableView cell.
        let alert = UIAlertController(title: "Send message Approve/Reject", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { _ in
            print("Accept button pressed")
            self.showAlertAccept(messageId: messageId)
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            print("Reject button pressed")
            self.showAlertReject(messageId: messageId)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    
    func showAlertAccept(messageId: String) {
        // Show alert to confrim/accept the message
        let alert = UIAlertController(title: "ACCEPT?", message: "Send message?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            //on pressing accept, handle message confirmation
            self.request.confirmOrRejectMessage(messageId: messageId, rejection: false) { [self] result in
                switch result {
                case .success(_):
                    //On successful rejection, handle response
                    print("confirmMessage successful")
                    self.fetchDataAndUpdateTableView()
                case .failure(let error):
                    // Handle the error here
                    print("confirmMessage failed: ", error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    func showAlertReject(messageId: String) {
        // Show alert to confirm you want to reject message
        let alert = UIAlertController(title: "Reject?", message: "Reject message", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
            //On pressing reject, handle message rejection
            self.request.confirmOrRejectMessage(messageId: messageId, rejection: true) { [self] result in
                switch result {
                case .success(_):
                    //On successful rejection, handle response
                    print("rejectMessage successful")
                    self.fetchDataAndUpdateTableView()
                case .failure(let error):
                    // Handle the error here
                    print("rejectMessage failed: ", error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    
    func fetchDataAndUpdateTableView(){
        //Fetch data from mongodb and udpate the tableView
        self.request.getMessages(endPoint: "pending") { [self] result in
            switch result {
            case .success(let json):
                // Handle JSON data for tableView
                self.messagesData = json
//                print(self.messagesData)
                print(json["statusCode"])
                DispatchQueue.main.async {
                    self.myTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

