//
//  giornoCell.swift
//  ITR2
//
//  Created by if65 on 10/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class giornoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var boxInterno: UIView!
    @IBOutlet weak var boxInternoTopBar: UIView!
    
    @IBOutlet weak var giornoSettimana: UILabel!
    @IBOutlet weak var giorno: UILabel!
    @IBOutlet weak var mese: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.boxInterno.layer.cornerRadius = 4.0
        self.boxInterno.layer.borderColor = defaultColor!.cgColor
        self.boxInterno.layer.borderWidth = 0.5
        self.boxInterno.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.boxInterno.layer.backgroundColor = UIColor.white.cgColor
        
        self.boxInternoTopBar.layer.cornerRadius = 4.0
        self.boxInternoTopBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.boxInternoTopBar.backgroundColor = defaultColor!
        
        self.giorno.textColor = defaultColor!
        self.mese.textColor = defaultColor!
        
        self.giornoSettimana.textColor = UIColor.white
        
    }
}
