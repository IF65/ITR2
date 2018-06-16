//
//  DataModel.swift
//  ITR2
//
//  Created by if65 on 10/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

var elencoSocieta = [String : Societa]()
var settimane = [Settimana]()


 //MARK:- Costanti
// ---------------------------------------------
let itmServer = "10.11.14.78"
let itmSocietaPath = "/itr/itr.php"

let gmtTimeZone = TimeZone(abbreviation: "GMT")
let offsetWeek = 0

 //MARK:- Config
// ---------------------------------------------
class Sede: Codable {
    var codice: String = ""
    var societa: String = ""
    var codiceCA: String = ""
    var codiceInterno: String = ""
    var codiceOrdinamento: Int = 100
    var dataApertura: String = ""
    var dataChiusura: String = ""
    var descrizione: String = ""
    var eliminata: Bool = false
    var ip: String = ""
    var tipo: String = "03"
}

class Area: Codable {
    var societa: String = ""
    var codice: Int = 0
    var descrizione: String = ""
    var sedi = [String]()
}

class Societa: Codable {
    var codice: String = ""
    var descrizione: String = ""
    var aree = [Area]()
    var sedi = [Sede]()
}

func updateConfigData() -> Bool {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = itmServer
    urlComponents.path = itmSocietaPath
    guard let url = urlComponents.url else { fatalError("Non può essere creata la url dai componenti!") }
    
    Alamofire.request(url, method: .post, parameters: ["functionName" : "elencoSocieta"], encoding: JSONEncoding.default)
        .responseJSON { response in
            switch response.result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                if let records = data as? [String:[String : AnyObject]] {
                    for (codiceSocieta, dettagliSocieta) in records {
                        // creo la società
                        let societa = Societa()
                        societa.codice = codiceSocieta
                        societa.descrizione = dettagliSocieta["descrizione"] as! String
                        
                        // aggancio le sedi
                        if let sedi = dettagliSocieta["sedi"] as? [String : AnyObject] {
                            for (codice, dettaglio) in sedi {
                                if let dettaglio = dettaglio as? [String : AnyObject] {
                                    let sede = Sede()
                                    sede.societa = codiceSocieta
                                    sede.codice = codice
                                    sede.codiceCA = dettaglio["codiceCA"] as! String
                                    sede.codiceInterno = dettaglio["codiceInterno"] as! String
                                    sede.codiceOrdinamento = Int(dettaglio["codiceOrdinamento"] as! String)!
                                    sede.dataApertura = dettaglio["dataApertura"] as! String
                                    sede.dataChiusura = dettaglio["dataChiusura"] as! String
                                    sede.descrizione = dettaglio["descrizione"] as! String
                                    if let eliminata = dettaglio["eliminata"] as! String? {
                                        sede.eliminata = true
                                        if eliminata == "0" {
                                            sede.eliminata = false
                                        }
                                    }
                                    sede.tipo = dettaglio["tipo"] as! String
                                    
                                    // aggiungo la sede all'elenco della societa
                                    societa.sedi.append(sede)
                                }
                            }
                        }
                        
                        // aggancio le aree
                        if let aree = dettagliSocieta["aree"] as? [String : AnyObject] {
                            for (codice, dettaglio) in aree {
                                let area = Area()
                                area.codice = Int(codice)!
                                area.descrizione = dettaglio["descrizione"] as! String
                                for codiceSede in dettaglio["sedi"] as! [String] {
                                    area.sedi.append(codiceSede)
                                }
                                societa.aree.append(area)
                            }
                        }
                        
                        elencoSocieta[codiceSocieta] = societa
                    }
                    saveConfigToDisc(elencoSocieta)
                }
            }
    }
    return false
}

func saveConfigToDisc(_ data: [String : Societa]) {
    let encoder = JSONEncoder()
    //encoder.outputFormatting = .prettyPrinted
    
    do {
        let jsonData = try encoder.encode(data)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = URL(fileURLWithPath: "config.json", relativeTo: documentDirectory)
        do {
            try jsonData.write(to: filePath)
        } catch {
            fatalError("Errore di scrittura json: \(error)")
        }
        
    } catch {
        fatalError("Errore di codifica json{elencoSocieta} :\(error)")
    }
}

func loadConfigFromDisc() -> [String : Societa]? {
    
    let decoder = JSONDecoder()
    
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let filePath = URL(fileURLWithPath: "config.json", relativeTo: documentDirectory)
    do {
        let json = try String(contentsOf: filePath, encoding: .utf8)
        do {
            return try decoder.decode([String : Societa].self, from: Data(json.utf8))
        } catch {
            return nil
        }
    } catch {
        return nil
    }
}

 //MARK:- Periodi
class Settimana {
    var numero: Int
    var anno: Int
    var inizio: Date
    var fine: Date
    var inizioAP: Date
    var fineAP: Date
    
    init(Numero numero: Int, Anno anno: Int) {
        self.numero = numero
        self.anno = anno
        
        var components = DateComponents()
        components.timeZone = gmtTimeZone
        components.weekOfYear = numero
        components.yearForWeekOfYear = anno
        components.weekday = 2  // lunedì
        self.inizio = Calendar.current.date(from: components)!
        self.inizioAP = Calendar.current.date(byAdding: .day, value: -364 + offsetWeek, to: self.inizio)!
        
        self.fine = Calendar.current.date(byAdding: .day, value: 6 , to: self.inizio)!
        self.fineAP = Calendar.current.date(byAdding: .day, value: -364 + offsetWeek, to: self.fine)!
    }
}

class Mese {
    var numero: Int
    var anno: Int
    var inizio: Date
    var fine: Date
    var inizioAP: Date
    var fineAP: Date
    
    init(Numero numero: Int, Anno anno: Int) {
        self.numero = numero
        self.anno = anno
        
        var components = DateComponents()
        
        var toAdd = DateComponents()
        toAdd.month = 1
        toAdd.day = -1
        
        components.timeZone = gmtTimeZone
        components.year = anno
        components.month = numero
        components.day = 1
        self.inizio = Calendar.current.date(from: components)!
        self.fine = Calendar.current.date(byAdding: toAdd, to: self.inizio)!
        
        components.year = anno - 1
        self.inizioAP = Calendar.current.date(from: components)!
        self.fineAP = Calendar.current.date(byAdding: toAdd, to: self.inizioAP)!
    }
}

class Periodo {
    let anno: Int
    var giorni = [Date]()
    var settimane = [Settimana]()
    var mesi = [Mese]()
    init(Anno anno: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = gmtTimeZone
        let date = dateFormatter.date(from: "\(anno)-01-05")!
        
        let weekRange = Calendar.current.range(of: .weekOfYear, in: .yearForWeekOfYear, for: date)!
        
        self.anno = anno
        for numeroSettimana in 1...weekRange.count {
            self.settimane.append(Settimana(Numero: numeroSettimana, Anno: anno))
        }
        
        for mese in 1...12 {
            self.mesi.append(Mese(Numero: mese, Anno: anno))
        }
    }
}




