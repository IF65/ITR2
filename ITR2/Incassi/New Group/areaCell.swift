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
    @IBOutlet weak var areaBox: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.areaBox.layer.borderColor = lightGrey.cgColor
        self.areaBox.layer.borderWidth = 0.5
        self.areaBox.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.areaBox.layer.backgroundColor = lightGrey.cgColor
        
        self.titolo.textColor = blueSM
    }
    
}
