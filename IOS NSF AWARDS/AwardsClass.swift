//
//  File.swift
//  NSF Awards temp
//
//  Created by JLM on 3/6/17.
//  Copyright © 2017 JLM. All rights reserved.
//
/*
 {
 "response" : {
 "award" : [ {
 "agency" : "NSF",
 "awardeeCity" : "MISSOULA",
 "awardeeName" : "University of Montana",
 "awardeeStateCode" : "MT",
 "fundsObligatedAmt" : "99911",
 "id" : "1052893",
 "piFirstName" : "Penelope",
 "piLastName" : "Kukuk",
 "date" : "09/20/2010",
 "title" : "Indigenous Women in Science Network (IWSN) Third Annual Meeting"
 } ]
 }
 }
 
 */

import UIKit

class AwardsClass {            // used to send to Details screen
    var awardID: String = ""
    var awardTitle: String = ""
    var awardState: String = ""
    var awardCity: String = ""
    var awardFunds: String = ""
    var awardPI: String = ""
    var awardDate: String = ""
    var awardInst: String = ""
    
    init (awardID: String, awardTitle: String, awardState: String, awardCity: String,
          awardFunds: String, awardPI: String, awardDate: String, awardInst: String) {
        self.awardID = awardID
        self.awardTitle = awardTitle
        self.awardState = awardState
        self.awardCity = awardCity
        self.awardFunds = awardFunds
        self.awardPI = awardPI
        self.awardDate = awardDate
        self.awardInst = awardInst
    }
    
}
