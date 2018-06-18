//
//  ViewController.swift
//  ITR2
//
//  Created by if65 on 10/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import UIKit

class IncassiViewController: UIViewController {
   
    @IBOutlet weak var verticalCollectionView: UICollectionView!
    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pannelloTotali: UIView!
    @IBOutlet weak var totaleVenduto: UILabel!
    @IBOutlet weak var totaleVendutoAP: UILabel!
    @IBOutlet weak var deltaVenduto: UILabel!
    @IBOutlet weak var deltaVendutoP: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        periodo = Periodo(Anno: 2018)
        tipoCalendarioSelezionato = TipoCalendario.giornaliero
        indiceCalendarioSelezionato = periodo?.getCurrent(Data: Date(), tipo: tipoCalendarioSelezionato!)
        horizontalCollectionView.scrollToItem(at: IndexPath(row: indiceCalendarioSelezionato!, section: 0), at: .centeredHorizontally, animated: true)
        
        indiceAreaSelezionata = 1
        
        pannelloTotali.layer.borderColor = lightGrey.cgColor
        pannelloTotali.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func aggiornamentoIncassi() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = itmServer
        urlComponents.path = itmItrPath
        guard let url = urlComponents.url else { fatalError("Non può essere creata la url dai componenti!") }
        
        var parameters = periodo?.getRequest(indice: indiceCalendarioSelezionato!, tipoCalendario: tipoCalendarioSelezionato!)
        parameters?.functionName = "aggiornaIncassi"
        
        do {
            let encoder = JSONEncoder()
            let body = try encoder.encode(parameters)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) {data,response,error in
                if let error = error {
                    print("Failure! \(error)")
                } else
                    if let response = response as? HTTPURLResponse,
                        response.statusCode == 200 {
                        if let data = data {
                            do {
                                let jsonDecoder = JSONDecoder()
                                let jsonIncassi =  try jsonDecoder.decode(JSONIncassi.self, from: data)
                                
                                incassi.incassi.removeAll()
                                for jsonIncasso in jsonIncassi.data {
                                    if jsonIncasso.codiceSocieta == societaSelezionata {
                                        incassi.incassi.append(Incasso(jsonIncasso: jsonIncasso))
                                    }
                                }
                                
                            } catch {
                                print("Errore di conversione: \(error)")
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                let formatter = NumberFormatter()
                                formatter.usesGroupingSeparator = true
                                formatter.alwaysShowsDecimalSeparator = true
                                formatter.currencyGroupingSeparator = "."
                                formatter.currencyDecimalSeparator = ","
                                formatter.decimalSeparator = ","
                                formatter.groupingSeparator = "."
                                formatter.maximumFractionDigits = 2
                                formatter.minimumFractionDigits = 2
                                formatter.currencySymbol = ""
                                
                                let totali = incassi.totaleVenduto()
                                
                                formatter.numberStyle = .currency
                                self.totaleVenduto.text = formatter.string(for: totali.totaleVenduto)
                                self.totaleVendutoAP.text = formatter.string(for: totali.totaleVendutoAP)
                                self.deltaVenduto.text = formatter.string(for: totali.deltaVenduto)
                                
                                formatter.numberStyle = .percent
                                self.deltaVendutoP.text = formatter.string(for: totali.deltaVendutoP)
                            }
                            return
                        }
                    } else {
                        print("Collegamento non riuscito: \(response!)")
                }
                
                DispatchQueue.main.async {
                    /*self.hasSearched = false
                     self.isLoading = false
                     self.topCollectionView.scrollToItem(at: IndexPath(item: self.periodo.getSelectedIndex(Per: self.tipoCalendario)!, section: 0), at: .centeredHorizontally, animated: true)
                     self.tableView.reloadData()
                     self.showNetworkError()*/
                }
            }
            dataTask.resume()
            
        } catch {
            print("JSON Error \(error)")
        }
    }
}
    
//MARK:- Table View
extension IncassiViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incassi.incassi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncassoCell", for: indexPath) as! IncassoCell
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.alwaysShowsDecimalSeparator = true
        formatter.currencyGroupingSeparator = "."
        formatter.currencyDecimalSeparator = ","
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.currencySymbol = ""
        formatter.numberStyle = .currency
        
        cell.sede.text = incassi.incassi[indexPath.row].codice
        cell.venduto.text = formatter.string(for: incassi.incassi[indexPath.row].venduto)
        cell.vendutoAP.text = formatter.string(for: incassi.incassi[indexPath.row].vendutoAP)
        
        return cell
    }
}

//MARK:- Collection Views (Hor, Vert)
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
            if tipoCalendarioSelezionato == .giornaliero {
                return periodo!.giorni.count
            } else if tipoCalendarioSelezionato == .settimanale {
                return periodo!.settimane.count
            } else if tipoCalendarioSelezionato == .mensile {
                return periodo!.mesi.count
            }
            return 1
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
            if tipoCalendarioSelezionato == .giornaliero {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "giornoCell", for: indexPath) as! giornoCell
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "it_IT")
                
                dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
                cell.giornoSettimana.text = dateFormatter.string(from: periodo!.giorni[indexPath.row])
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
                cell.mese.text = dateFormatter.string(from: periodo!.giorni[indexPath.row])
                dateFormatter.setLocalizedDateFormatFromTemplate("dd")
                cell.giorno.text = dateFormatter.string(from: periodo!.giorni[indexPath.row])
                
                return cell
            }
            
           return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == horizontalCollectionView {
            indiceCalendarioSelezionato = indexPath.row
        } else {
            indiceAreaSelezionata = indexPath.row
        }
        aggiornamentoIncassi()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animateAlongsideTransition(in: nil, animation: nil) {(context) -> Void in
            let selezioneCorrente = periodo!.getCurrent(Data: Date(), tipo: .giornaliero)!
            self.horizontalCollectionView.scrollToItem(at: IndexPath(item: selezioneCorrente, section: 0), at: .centeredHorizontally, animated: true)
            return
        }
    }
}

extension IncassiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === verticalCollectionView {
            return CGSize(width: Int(100), height: Int(50))
        } else {        
            if tipoCalendarioSelezionato == TipoCalendario.giornaliero {
                return CGSize(width: Int(60), height: Int(60))
            } else if tipoCalendarioSelezionato == TipoCalendario.settimanale {
                return CGSize(width: Int(120), height: Int(60))
            } else {
                return CGSize(width: Int(60), height: Int(60))
            }
        }
    }
}

