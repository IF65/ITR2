//
//  areaCell.swift
//  ITR2
//
//  Created by if65 on 10/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class areaCell: UICollectionViewCell {
    
    @IBOutlet weak var titolo: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.backgroundColor = UIColor.green.cgColor
    }
    
}
