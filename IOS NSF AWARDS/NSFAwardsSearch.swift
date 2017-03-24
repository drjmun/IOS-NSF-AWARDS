//
//  ViewController.swift
//  IOS NSF AWARDS
//
//  Created by JLM on 3/22/17.
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
extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}

var nsfAwards = [AwardsClass]()
var offset: Int = -24
var oldSearch: String = ""
var idForDetails: String = ""
var selectedAward: AwardsClass?
var projOnly: String = "false"


class NSFAwardsSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
//    @IBOutlet weak var searchField: UITextField!        // text entered by user
//    @IBOutlet weak var busyContainer: UIView!           // holds the activity indicator
//    @IBOutlet weak var awardsList: UITableView!         // shows list of awards found
//    @IBOutlet weak var projOutcomesOnly: UISwitch!      // toggle between awards with proj outcomes only
//    @IBOutlet weak var showBusy: UIActivityIndicatorView!   // activity indicator
//    @IBOutlet weak var loadingLabel: UILabel!           // text of activity indicator
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var showBusy: UIActivityIndicatorView!
    @IBOutlet weak var awardsList: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var projOutcomesOnly: UISwitch!
    @IBOutlet weak var busyContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awardsList.dataSource = self
        awardsList.delegate = self
        self.searchField.delegate = self        // for hiding keyboard when done
        //projOutcomesOnly.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)  // reduce size of switch
        //projOnlyToggle(projOutcomesOnly)        // Project Outcomes Report true/false?
        busyContainer.center = awardsList.center    // contains the activity indicator
        awardsList.addSubview(busyContainer)
        loadingLabel.isHidden = true            // activity indcator label is initially hidden
        if !internetAvail() {myAlert(message: "No Internet Access")}
    }
    
    // this contains how many rows are to be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nsfAwards.count              // return size of array
    }
    
    // used to populate each cell of the table view with award title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AwardsTableViewCell
        let title = nsfAwards[indexPath.row].awardTitle
        cell.awardsCell.text = title
        return cell
    }
    
    // hides the keyboard if screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)              // hide the keyboard
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // fills the awards array with fake stuff to busyh wait completes
    func fakeIt (reason: String, searchTerm: String) {
        // FAKE OUT COMPLETION OF FILLING OUT NSFAWARDS ARRAY
        for i in 1...25 {
            nsfAwards.append(AwardsClass(awardID: "0", awardTitle: String(i) + reason + searchTerm + " NOT FOUND", awardState: " ", awardCity: " ", awardFunds: "0", awardPI: " ", awardDate: " ", awardInst: " "))
        }
    }
    
    // display and ALERT message and waits for user to acknowledge
    func myAlert (message: String) {
        let showAlert = UIAlertController(title: "ALERT", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (ACTION) in
        }
        
        showAlert.addAction(okAction)
        
        present(showAlert, animated: true, completion: nil)
    }
    
    // check to make sure there is internet access
    func internetAvail() -> Bool {
        if currentReachabilityStatus == .reachableViaWiFi { return true}
        else if currentReachabilityStatus == .reachableViaWWAN { return true}
        else {return false}
    }
    
    
    //
    // this is the workhorse function... downloads data from url and populates array with award info
    //
    func getNSFAwardsData(searchTerm: String) {
        
        offset += 25
        let url = URL(string: "http://api.nsf.gov/services/v1/awards.json?keyword="+searchTerm+"&offset="+String(offset)+"&projectOutcomesOnly="+projOnly)
        if (url != nil) {print(url!)}
        else {fakeIt(reason: "*Invalid search term", searchTerm: searchTerm)}
        nsfAwards = []                             // initialize the awards array that is to contain the info
        // read the JSON file
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil
            {
                print("URLSESSION ERROR")
                self.myAlert(message: "URL SESSION ERROR")
            } else                              // read was successful
            {
                if let content = data
                {
                    do
                    {   // serialize the JSON data so it can be parsed
                        let myJson = try JSONSerialization.jsonObject(with: content, options:[]) as AnyObject
                        
                        let feedRoot = myJson["response"] as? Dictionary<String, AnyObject>  // locate "response" dictionary
                        var awards = [AnyObject]()
                        awards = (feedRoot?["award"] as? Array<AnyObject>)! // locate "awards" as an array
                        print("got awards array: " +  String(describing: awards.count))
                        if (awards.isEmpty) {
                            self.fakeIt(reason: "*JSON Error in awards", searchTerm: searchTerm)
                        }
                        var count = 0
                        if ((awards.count) > 0) {
                            // print("AWARDS COUNT: ", Int((awards?.count)!))
                            for award in awards {   // go thru each award in awards array
                                let awardDict = award as? Dictionary<String, AnyObject>
                                count += 1
                                let xtitle = awardDict?["title"] as? String  // extract award title
                                let title = String(count+offset-1) + ". " + xtitle!
                                let id = awardDict?["id"] as? String        // extract award ID... etc
                                let city = awardDict?["awardeeCity"] as? String
                                let state = awardDict?["awardeeStateCode"] as? String
                                let funds = awardDict?["fundsObligatedAmt"] as? String
                                let piFirst = awardDict?["piFirstName"] as? String
                                let piLast = awardDict?["piLastName"] as? String
                                let date = awardDict?["date"] as? String
                                let inst = awardDict?["awardeeName"] as? String
                                
                                // populate the awards array
                                nsfAwards.append(AwardsClass(awardID: id!, awardTitle: title, awardState: state!, awardCity: city!, awardFunds: funds!, awardPI: piFirst!+" "+piLast!, awardDate: date!, awardInst: inst!))
                                // print(id!,title!,nsfAwards.count)
                            }  // end for
                        } else {
                            self.fakeIt (reason: "*AWARDS NOT FOUND: ", searchTerm: searchTerm) // search term not found
                        }
                    }
                    catch
                    {
                        self.fakeIt(reason: "*Error serializing JSON with: ",searchTerm: searchTerm)
                    }
                } // end content = data
            }
        }  // end task session
        task.resume()
        
    }  // end NSFGetAwardsData
    
    @IBAction func awardSearchBtn(_ sender: Any) {
        if !internetAvail() {myAlert(message: "No Internet Access") }
        
        searchField.resignFirstResponder()                           // hide keyboard if present
        if self.searchField.text!.isNumber {                          // was an Award ID or Search Term entered
            selectedAward = getAwardDetails(searchTerm: self.searchField.text!)
            self.performSegue(withIdentifier: "selectedID", sender: nil) // An Award ID (number) was entered...get details
            
        } else {
            loadingLabel.isHidden = false
            showBusy.startAnimating()                                   // display activity indicator
            
            DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async { // async task so that activity indicator shows
                
                if self.searchField.text != oldSearch {      // new search term?
                    offset = -24                    // reset everything
                    oldSearch = self.searchField.text!
                }
                nsfAwards = []
                self.getNSFAwardsData(searchTerm: self.searchField.text!)
                while (nsfAwards.count < 25) {                         // busy-wait for awards data to be collected
                }
                // print("Returned from getNSFAwardsData", nsfAwards.count, nsfAwards[0].awardID, nsfAwards[0].awardTitle)
                DispatchQueue.main.async {                                  // async done... go back to UI task
                    self.showBusy.stopAnimating()
                    self.loadingLabel.isHidden = true                        // stop activity indicator
                    let tag = nsfAwards[0].awardTitle
                    if tag.range(of: "*") != nil {          // error return?
                        self.myAlert(message: "Error")
                    }
                    
                    self.awardsList.reloadData()                            // show updated table
                }
            }
        } // dispatch queue
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  // SearchDetails view controller display details
        let detailsController = segue.destination as! SearchDetails  // SearchDetails is name of 2nd controller
        
        if segue.identifier == "selectedID" {                         // AwardsDetail is the link to 2nd controller
            detailsController.awardDetail = selectedAward             // send over necessary info for the selected award
        }
    }
    
    @IBAction func projOnlyToggle(_ sender: UISwitch) {
        if projOutcomesOnly.isOn {projOnly = "true"}
        else
        {projOnly = "false"}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  // 2nd view controller setup
        selectedAward = nsfAwards[indexPath.row]            // extract the award info
        performSegue(withIdentifier: "selectedID", sender: nil) // an award was selected
    }
}  // end NSFAwardSearch
