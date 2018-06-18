//
//  VerticalCollectionView.swift
//  ITR2
//
//  Created by if65 on 18/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class VerticalCollectionView: UICollectionView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = lightGrey.cgColor
        self.layer.borderWidth = 1.0
    }

}
