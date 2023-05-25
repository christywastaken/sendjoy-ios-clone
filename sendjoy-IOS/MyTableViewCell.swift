//
//  MyTableViewCell.swift
//  sendjoy-IOS
//
//  Created by Christian Harrison on 01/03/2023.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            layer.cornerRadius = 15
            layer.masksToBounds = true
            
        }
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var ipLabel: UILabel!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var sentimentLabel: UILabel!
    
}
