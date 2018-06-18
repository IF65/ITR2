//
//  IncassoCellTableViewCell.swift
//  ITR2
//
//  Created by if65 on 18/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class IncassoCell: UITableViewCell {

    @IBOutlet weak var sede: UILabel!
    @IBOutlet weak var venduto: UILabel!
    @IBOutlet weak var vendutoAP: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
