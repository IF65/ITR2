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
    
    func getSede(CodiceInterno codiceInterno:String) -> Sede? {
        for sede in self.sedi {
            if sede.codiceInterno == codiceInterno {
                return sede
            }
        }
        return nil
    }
    
    func getSede(Codice codice:String) -> Sede? {
        for sede in self.sedi {
            if sede.codice == codice {
                return sede
            }
        }
        return nil
    }
    
    func getArea(Codice codice: Int) -> Area? {
        for area in self.aree {
            if area.codice == codice {
                return area
            }
        }
        return nil
    }
    
    func getArea(Descrizione descrizione:String) -> Area? {
        for area in self.aree {
            if area.descrizione == descrizione {
                return area
            }
        }
        return nil
    }
}

func updateConfigData() -> Bool {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = itmServer
    urlComponents.path = itmItrPath
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

//MARK:- Incassi
// ---------------------------------------------

struct JSONIncasso: Decodable {
    let codiceSocieta: String
    let codiceCed: String
    let codice: String
    let clienti: String
    let clientiAP: String
    let clientiOb: String
    let giornataClienti: String
    let giornataPassaggi: String
    let giornataVenduto: String
    let giorniApertura: String
    let giorniAperturaAP: String
    let oraUltimoscontrino: String
    let oreLavorate: String
    let oreLavorateAP: String
    let oreLavorateOb: String
    let passaggi: String
    let passaggiAP: String
    let passaggiOb: String
    let venduto: String
    let vendutoAP: String
    let vendutoOb: String
}

struct JSONIncassi: Decodable {
    let draw: Int
    let recordsFiltered: Int
    let recordsTotal: Int
    let data: [JSONIncasso]
}
struct JSONIncassiRequest: Encodable {
    var dataCorrente: String
    var dataCorrenteAP: String
    var dataFine: String
    var dataFineAP: String
    var dataInizio: String
    var dataInizioAP: String
    var draw: Int
    var functionName: String
}

class Incasso {
    var clienti: Int = 0
    var clientiAP: Int = 0
    var clientiOb: Int = 0
    var codice: String = ""
    var codiceInterno: String = ""
    var giornataClienti: Int = 0
    var giornataPassaggi: Int = 0
    var giornataVenduto: Double = 0.0
    var giorniApertura: Int = 0
    var giorniAperturaAP: Int = 0
    var oraUltimoscontrino: String = ""
    var oreLavorate: Float = 0
    var oreLavorateAP: Float = 0
    var oreLavorateOb: Float = 0
    var passaggi: Int = 0
    var passaggiAP: Int = 0
    var passaggiOb: Int = 0
    var venduto: Double = 0.0
    var vendutoAP: Double = 0.0
    var vendutoOb: Double = 0.0
    
    init(jsonIncasso: JSONIncasso) {
        self.clienti = Int(jsonIncasso.clienti)!
        self.clientiAP = Int(jsonIncasso.clientiAP)!
        self.clientiOb = Int(jsonIncasso.clientiOb)!
        self.codice = jsonIncasso.codiceCed
        self.codiceInterno = jsonIncasso.codice
        self.giornataClienti = Int(jsonIncasso.giornataClienti)!
        self.giornataPassaggi = Int(jsonIncasso.giornataPassaggi)!
        self.giornataVenduto = Double(jsonIncasso.giornataVenduto)!
        self.giorniApertura = Int(jsonIncasso.giorniApertura)!
        self.giorniAperturaAP = Int(jsonIncasso.giorniAperturaAP)!
        self.oraUltimoscontrino = jsonIncasso.oraUltimoscontrino
        self.oreLavorate = Float(jsonIncasso.oreLavorate)!
        self.oreLavorateAP = Float(jsonIncasso.oreLavorateAP)!
        self.oreLavorateOb = Float(jsonIncasso.oreLavorateOb)!
        self.passaggi = Int(jsonIncasso.passaggi)!
        self.passaggiAP = Int(jsonIncasso.passaggiAP)!
        self.passaggiOb = Int(jsonIncasso.passaggiOb)!
        self.venduto = Double(jsonIncasso.venduto)!
        self.vendutoAP = Double(jsonIncasso.vendutoAP)!
        self.vendutoOb = Double(jsonIncasso.vendutoOb)!
    }
}

struct TotaliIncasso {
    var totaleVenduto: Double = 0.0
    var totaleVendutoAP: Double = 0.0
    var deltaVenduto: Double = 0.0
    var deltaVendutoP: Double = 0.0
}

class Incassi {
    var incassi = [Incasso]()
    
    init() {
        self.incassi = []
    }
    
    func indiceSede(_ sede: String) -> Int? {
        for indice in 0..<self.incassi.count {
            if sede == incassi[indice].codice {
                return indice
            }
        }
        return nil
    }
    
    func totaleVenduto(_ codiciSede:[String]) -> TotaliIncasso {
        
        var totali = TotaliIncasso()
        for incasso in self.incassi {
            if let _ = codiciSede.first(where: {$0 == incasso.codice}) {
                totali.totaleVenduto += incasso.venduto
                totali.totaleVendutoAP += incasso.vendutoAP
            }
        }
        totali.deltaVenduto = totali.totaleVenduto - totali.totaleVendutoAP
        totali.deltaVendutoP = totali.totaleVendutoAP != 0 ? totali.deltaVenduto/totali.totaleVendutoAP : 0
        
        return totali
    }
}

//MARK:- Periodi
// ---------------------------------------------
enum TipoCalendario {
    case giornaliero
    case settimanale
    case mensile
    case annuale
    case periodo
}

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
        
        let dateRange = Calendar.current.range(of: .day, in: .year, for: date)!
        for dayNumber in 1..<dateRange.upperBound {
            var newDateComponent = DateComponents()
            newDateComponent.timeZone = gmtTimeZone
            newDateComponent.year = anno
            newDateComponent.day = dayNumber
            self.giorni.append(Calendar.current.date(from: newDateComponent)!)
        }
    }
    
    func getCurrent(Data data: Date, tipo: TipoCalendario) -> Int? {
        var components = DateComponents()
        components = Calendar.current.dateComponents(in: gmtTimeZone!, from: data)
        
        if (tipo == .giornaliero) {
            if let selectedIndex = self.giorni.index(where: {Calendar.current.component(.day, from: $0) == components.day && Calendar.current.component(.month, from: $0) == components.month}) {
                return selectedIndex
            } else {
                return nil
            }
        } else if (tipo == .settimanale) {
            if let selectedIndex = self.settimane.index(where: {$0.numero == components.weekOfYear}) {
                return selectedIndex
            } else {
                return nil
            }
        } else if (tipo == .mensile) {
            if let selectedIndex = self.mesi.index(where: {$0.numero == components.month}) {
                return selectedIndex
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func getRequest(indice: Int, tipoCalendario: TipoCalendario) -> JSONIncassiRequest? {
        var request: JSONIncassiRequest?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = gmtTimeZone
        
        if tipoCalendario == .giornaliero {
            let data = self.giorni[indice]
            
            var toAdd = DateComponents()
            toAdd.day = -364
            toAdd.timeZone = gmtTimeZone
            let dataAP = Calendar.current.date(byAdding: toAdd, to: data)!
            
            let dataCorrente = dateFormatter.string(from: data)
            let dataCorrenteAP = dateFormatter.string(from: dataAP)
            let dataInizio = dateFormatter.string(from: data)
            let dataInizioAP = dateFormatter.string(from: dataAP)
            let dataFine = dateFormatter.string(from: data)
            let dataFineAP = dateFormatter.string(from: dataAP)
            
            request = JSONIncassiRequest(dataCorrente: dataCorrente, dataCorrenteAP: dataCorrenteAP, dataFine: dataFine, dataFineAP: dataFineAP, dataInizio: dataInizio, dataInizioAP: dataInizioAP, draw: 0, functionName: "")
            
            return request
        } else if tipoCalendario == .settimanale {
            let settimana = self.settimane[indice]
            
            let dataCorrente = dateFormatter.string(from: settimana.fine)
            let dataCorrenteAP = dateFormatter.string(from: settimana.fineAP)
            let dataInizio = dateFormatter.string(from: settimana.inizio)
            let dataInizioAP = dateFormatter.string(from: settimana.inizioAP)
            let dataFine = dateFormatter.string(from: settimana.fine)
            let dataFineAP = dateFormatter.string(from: settimana.fineAP)
            
            request = JSONIncassiRequest(dataCorrente: dataCorrente, dataCorrenteAP: dataCorrenteAP, dataFine: dataFine, dataFineAP: dataFineAP, dataInizio: dataInizio, dataInizioAP: dataInizioAP, draw: 0, functionName: "")
            
            return request
        }
        
        return nil
    }
}




