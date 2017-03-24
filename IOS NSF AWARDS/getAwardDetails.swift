//
//  getAwardDetails.swift
//  NSF Awards
//
//  Created by JLM on 3/12/17.
//  Copyright © 2017 JLM. All rights reserved.
//

import Foundation

var awards: Dictionary<String, AnyObject> = ["":"" as AnyObject]
var count = 0
var thisAward = AwardsClass(awardID: "", awardTitle: "", awardState: "", awardCity: "", awardFunds: "", awardPI: "", awardDate: "", awardInst: "")
/*
 getAwardDetails gets called when user has made a selection from table OR user has entered an award ID
 */
func getAwardDetails (searchTerm: String) -> AwardsClass   {
    let myUrl = URL(string: "http://api.nsf.gov/services/v1/awards/"+searchTerm+".json")!
    // print("IN getAwardDetails: " + String (describing: myUrl))
    let task = URLSession.shared.dataTask(with: myUrl) {(data, response, error) in
        if error != nil
        {
            print("URLSESSION ERROR")
        } else                              // read was successful
        {
            if let content = data
            {
                do
                {   // serialize the JSON data so it can be parsed
                    let myJson = try JSONSerialization.jsonObject(with: content, options:[]) as AnyObject
                    
                    let feedRoot = myJson["response"] as? Dictionary<String, AnyObject>  // locate "response" dictionary
                    let awards = feedRoot?["award"] as? Array<AnyObject> // locate "awards" an array
                    print(awards!)
                    if ((awards?.count)! > 0) {
                        print("AWARDS COUNT: ", Int((awards?.count)!))
                        for award in awards! {   // go thru each award in awards array
                            let awardDict = award as? Dictionary<String, AnyObject>
                            print("AWARD DICT")
                            print (awardDict!)
                            let xtitle = awardDict?["title"] as? String  // extract award title
                            let title = "1. " + xtitle!
                            let id = awardDict?["id"] as? String        // extract award ID... etc
                            let city = awardDict?["awardeeCity"] as? String
                            let state = awardDict?["awardeeStateCode"] as? String
                            let funds = awardDict?["fundsObligatedAmt"] as? String
                            let piFirst = awardDict?["piFirstName"] as? String
                            let piLast = awardDict?["piLastName"] as? String
                            let date = awardDict?["date"] as? String
                            let inst = awardDict?["awardeeName"] as? String
                            // print(title, id!, city!, state!, funds!, piFirst!, piLast!, date!, inst!)
                            
                            // package the obtained info to send back
                            thisAward = AwardsClass(awardID: id!, awardTitle: title, awardState: state!, awardCity: city!, awardFunds: funds!, awardPI: piFirst!+" "+piLast!, awardDate: date!, awardInst: inst!)
                        }
                        
                    } else {
                        print (searchTerm + ":  AWARD NOT FOUND")
                        thisAward = AwardsClass (awardID: searchTerm, awardTitle: "AWARD NOT FOUND", awardState: "", awardCity: "", awardFunds: "0", awardPI: "", awardDate: String(describing: Date()), awardInst: "NATIONAL SCIENCE FOUNDATION")
                    }
                }
                catch
                {
                    print("Error serializing JSON")
                }
            } // end content = data
        }
    }  // end task session
    
    task.resume()
    sleep(3)                                    // THIS IS ACTUALLY A BUSY WAIT FOR TASK TO COMPLETE
    
    return thisAward
    
}  // end getAwardDetails
