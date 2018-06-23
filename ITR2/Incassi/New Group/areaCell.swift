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
    
    override var isSelected: Bool {
        didSet {
            if isSelected { // Selected cell
                //self.titolo.textColor = UIColor.red
                self.areaBox.layer.borderColor = UIColor.red.cgColor
            } else { // Normal cell
                //self.titolo.textColor = blueSM
                self.areaBox.layer.borderColor = lightGrey.cgColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.backgroundColor = UIColor.white.cgColor
        
        //self.areaBox.layer.cornerRadius = 4.0
       self.areaBox.layer.borderColor = lightGrey.cgColor
        self.areaBox.layer.borderWidth = 2
        //self.areaBox.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner,.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        self.areaBox.layer.backgroundColor = lightGrey.cgColor
        
        self.titolo.textColor = blueSM
    }
    
}
