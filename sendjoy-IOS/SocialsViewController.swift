//
//  SocialsViewController.swift
//  sendjoy-IOS
//
//  Created by Christian Harrison on 08/03/2023.
//

import UIKit
import SwiftyJSON

class SocialsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let request = Requests()
    var messagesData:JSON=[]
    @IBOutlet weak var socialsTable: UITableView!
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Socials Approval"
        socialsTable.dataSource = self
        socialsTable.delegate = self
        
        fetchDataAndUpdateTableView()
        
        //Sets up refreshControl for myTable tableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshVC), for: .valueChanged)
        socialsTable.refreshControl = refreshControl
        
        activitySpinner.isHidden = true
        self.activitySpinner.startAnimating()
        
    }
    
    @IBAction func postToSocialsButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Post to socials", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            print("Accept button pressed postToSocials")
            DispatchQueue.main.async {
                self.activitySpinner.isHidden = false
                self.activitySpinner.startAnimating()
            }
            
            self.request.postToSocials { [self] result in
                switch result {
                case .success(let statusCode):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Post to socials statusCode:", message: statusCode as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                        self.activitySpinner.isHidden = true
                    }
                    print("-- postToSocialsButtonPressed Success: ",statusCode)
                case .failure(let error):
                    print("-- postToSocialsButtonPressed Failure: ",error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        print(messagesData[indexPath.row])
        cell.messageTextView.text = rowData["cleanedMessage"].string
        cell.ipLabel.text = rowData["ipAddress"].string
        cell.phoneNumberLabel.text = rowData["phoneNumber"]["e164"].string
        cell.sentimentLabel.isHidden = true
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageId = messagesData[indexPath.row]["_id"].string ?? "null"
        showAlertGeneral(messageId: messageId)
    }
    
    
    func showAlertGeneral(messageId: String) {
        //Opens actionsheet after selecting tableView cell.
        let alert = UIAlertController(title: "Socials Approve/Reject", message: "", preferredStyle: .actionSheet)
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
        let alert = UIAlertController(title: "Approve?", message: "Approve for socials?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { _ in
            //on pressing accept, handle message confirmation
            DispatchQueue.main.async {
                self.activitySpinner.isHidden = false
                self.activitySpinner.startAnimating()
            }
            self.request.confirmOrRejectSocials(messageId: messageId, socialsStatus: "approved") { [self] result in
                switch result {
                case.success(_):
                    print("socialStatus approved successful")
                    self.fetchDataAndUpdateTableView()
                    DispatchQueue.main.async {
                        self.activitySpinner.isHidden = true
                    }
                case.failure(let error):
                    print("approved socials failed: ", error)
                    DispatchQueue.main.async {
                        self.activitySpinner.isHidden = true

                    }
                }
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showAlertReject(messageId: String) {
       // Show alert to confirm you want to reject message
        let alert = UIAlertController(title: "Reject?", message: "Reject from socials?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
            //On pressing reject, handle message rejection
            self.request.confirmOrRejectSocials(messageId: messageId, socialsStatus: "rejected") { [self] result in
                switch result {
                case.success(_):
                    print("socialStatus rejected successful")
                    self.fetchDataAndUpdateTableView()
                case.failure(let error):
                    print("rejected socials failed: ", error)
                }
                
            }
           
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    
    func fetchDataAndUpdateTableView(){
        //Fetch data from mongodb and udpate the tableView
        self.request.getMessages(endPoint:"socials/pending") { [self] result in
            switch result {
            case .success(let json):
                // Handle JSON data for tableView
                self.messagesData = json
//                print(self.messagesData)
                print(json["statusCode"])
                DispatchQueue.main.async {
                    self.socialsTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
