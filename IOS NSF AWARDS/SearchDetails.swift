//
//  Search Details.swift
//  NSF Awards
//
//  Created by JLM on 2/27/17.
//  Copyright © 2017 JLM. All rights reserved.
//

import UIKit

class SearchDetails: UIViewController {
    
    @IBOutlet weak var textField: UITextView!       // holds the abstract or proj outcomes
    @IBOutlet weak var searchLabel: UILabel!        // sent from the NSF SEARCH view controller
    @IBOutlet weak var titleLabel: UILabel!         // contains the various text fields
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var instLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var piLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fundsLabel: UILabel!
    
    @IBOutlet weak var absProj: UILabel!
    var awardsText: String = ""          // contains Abstract or Outcomes Report
    var awardDetail: AwardsClass?        // comes from NSF Search contains award data
    var abstract: Bool = true
    var searchFor: String = "abstractText" // contains either abstractText or projectOutcomesReport
    var url: URL?                       // contains the url to communicated with NSF Awards
    var counter = 0
    var absText: String = ""
    var POtext: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        absProj.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.absProjSelector))
        tapGesture.numberOfTapsRequired = 2
        absProj.addGestureRecognizer(tapGesture)
        
        abstract = false                    // setup for next toggle
        let awardID = awardDetail!.awardID      // awardDetail structure contains all of the info for a specific award
        if Int(awardID) == 0 {              // if a 0 was sent then the search term failed
            absText = "Award NOT FOUND"
        }
        // get the award's Abstract
        url = URL(string: "http://api.nsf.gov/services/v1/awards.json?id="+awardID+"&printFields=abstractText")!
        searchFor = "abstractText"
        getNSFAwardsData(searchTerm: awardID)                   // get the abstract or proj outcomes data
        while (awardsText.characters.count == 0) { }               // busy wait
        absText = "ABSTRACT: " + awardsText
        
        // get the award's Project Outcomes Report (if it exists)
        url = URL(string: "http://api.nsf.gov/services/v1/awards/" + awardID + "/projectoutcomes.json")!
        searchFor = "projectOutComesReport"
        getNSFAwardsData(searchTerm: awardID)                   // get the abstract or proj outcomes data
        while (awardsText.characters.count == 0) { }                // busy wait
        POtext = "PROJECT OUTCOME: " + awardsText
        
        // populate the view with the award specific info
        titleLabel.text = awardDetail?.awardTitle                   // populate the the data
        idLabel.text = "ID: " + (awardDetail?.awardID)!
        instLabel.text = "Institution: "+(awardDetail?.awardInst)!
        dateLabel.text = "Award Date: " + (awardDetail?.awardDate)!
        piLabel.text = "PI: " + (awardDetail?.awardPI)!
        stateLabel.text = "State: " + (awardDetail?.awardState)!
        let xmoney = Int((awardDetail?.awardFunds)!)
        let money = NSNumber(value: xmoney!)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .currency
        fundsLabel.text = "Funds: " + formatter.string(from: money)!
        absProj.text = "Abstract Summary"
        textField.text = absText                 // display the read text... initially it's the Abstract text
    }
    
    // this is the workhorse function... gets the requested information
    func getNSFAwardsData(searchTerm: String) {  // get Abstract or Outcomes Report
        
        // getURL(searchTerm: searchTerm)          // set up the url to get the necessary data... toggle abstract
        // print(url!)
        // read the JSON file
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil
            {
                print("URLSESSION ERROR")
            } else                              // read was successful... parse the data
            {
                if let content = data
                {
                    myDo: do
                    {   // serialize the JSON data so it can be parsed
                        let myJson = try JSONSerialization.jsonObject(with: content, options:[]) as AnyObject
                        
                        let feedRoot = myJson["response"] as? Dictionary<String, AnyObject>  // locate "response" dictionary
                        var awardText = feedRoot?["award"] as? Array<Dictionary <String, String > >// locate "awards" an array
                        // print(awardText!)
                        if (awardText?.isEmpty)! {
                            self.awardsText = "ABSTRACT/PROJECT OUTCOMES FOR: " + searchTerm + " NOT FOUND"
                            break myDo
                        }
                        if let abstractORproj = awardText?[0] {       // will contain abstract or project outcomes data... if it exists
                            
                            // self.awardsText = (abstractORproj?[self.searchFor]!)!// search for abstract or projectoutcomes
                            if (abstractORproj[self.searchFor]) != nil{
                                self.awardsText = (abstractORproj[self.searchFor]!) // found it!!
                            } else {
                                self.awardsText = self.searchFor + "... NOT FOUND"   // didn't find what looking for
                            }
                        } else {
                            self.awardsText = "ABSTRACT/PROJECT OUTCOMES FOR: " + searchTerm + " NOT FOUND"
                            
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
    }  // end NSFGetAwardsData
    
    
    func absProjSelector() {                // on double tap toggles between Abstract and Outcomes
        if abstract {
            absProj.text = "Abstract Summary"
            abstract = false
            textField.text = absText            // update with Abstract
            print("ABSTRACT: ")
        } else {
            absProj.text = "Project Outcomes Report"
            abstract = true
            textField.text = POtext             // update with Project Outcomes Report
            print("PROJECT OUTCOMES: ")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
