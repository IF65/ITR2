//
//  mainTableCell.swift
//  ITR2
//
//  Created by if65 on 19/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class MainTableCell: UITableViewCell {

    @IBOutlet weak var sede: UILabel!
    @IBOutlet weak var descrizione: UILabel!
    @IBOutlet weak var totale: UILabel!
    @IBOutlet weak var deltaP: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sede.textColor = blueSM
        totale.textColor = blueSM
        deltaP.textColor = blueSM
        descrizione.textColor = blueSM
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
