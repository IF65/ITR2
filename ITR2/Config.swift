//
//  Config.swift
//  ITR2
//
//  Created by if65 on 18/06/2018.
//  Copyright © 2018 if65. All rights reserved.
//

import Foundation
import UIKit

var societaSelezionata = "08"
var elencoSocieta = [String : Societa]()
//var settimane = [Settimana]()


// MARK:- Variabili
// ---------------------------------------------
var tipoCalendarioSelezionato: TipoCalendario?
var indiceCalendarioSelezionato: Int?
var indiceAreaSelezionata: Int?
var periodo: Periodo?
var incassi = Incassi()

// MARK:- Costanti
// ---------------------------------------------
public let itmServer = "10.11.14.78"
public let itmItrPath = "/itr/itr.php"

let alphaSM: CGFloat = 1.0

let blueSM = UIColor(red: 0.0, green: 85/255, blue: 145/255, alpha: 1)
let purpleSM = UIColor(red: 246/255, green: 21/255, blue: 147/255, alpha: 1)
let darkGreen = UIColor(red: 0, green: 102/255, blue: 51/255, alpha: 1)
let sephia = UIColor(red: 250/255, green: 235/255, blue: 215/255, alpha: 1.0)
let lightGrey = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)

let gmtTimeZone = TimeZone(abbreviation: "GMT")
let offsetWeek = 0
