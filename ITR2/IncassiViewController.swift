//
//  ViewController.swift
//  ITR2
//
//  Created by if65 on 10/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class IncassiViewController: UIViewController {
    
    let periodo = Periodo(Anno: 2018)

    @IBOutlet weak var verticalCollectionView: UICollectionView!
    @IBOutlet weak var HorizontalCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verticalCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension IncassiViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === verticalCollectionView {
            return 1
        } else {
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === verticalCollectionView {
            if let societa = elencoSocieta["08"] {
                return societa.aree.count
            }
            return 0
        } else {
            return periodo.settimane.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === verticalCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "areaCell", for: indexPath) as! areaCell
            if let societa = elencoSocieta["08"] {
                cell.titolo.text = societa.aree[indexPath.row].descrizione
            } else {
                cell.titolo.text = ""
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "periodoCell", for: indexPath) as! periodoCell
            cell.giornoSettimana.text = "\(periodo.settimane[indexPath.row].numero)"
            return cell
        }
    }
}

extension IncassiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === verticalCollectionView {
            return CGSize(width: Int(120), height: Int(60))
        } else {
            return CGSize(width: Int(60), height: Int(60))
        }
    }
}

