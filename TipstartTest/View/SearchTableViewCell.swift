//
//  SearchTableViewCell.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 31.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoUrl: UILabel!
    @IBOutlet weak var nameLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
