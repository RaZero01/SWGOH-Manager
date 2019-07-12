//
//  SearchVC.swift
//  SWGOH Manager
//
//  Created by Konstantin Razinkov on 20/11/2018.
//  Copyright © 2018 RaZero01. All rights reserved.
//

import UIKit
import Firebase
import Alamofire


var players: [String] = []


var chosenGuild = ""
var chosenShip = ""
var stars = ""

class SearchVC: UIViewController {
    @IBOutlet weak var playersText: UITextView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var guildPicker: UIPickerView!
    @IBOutlet weak var shipPicker: UIPickerView!
    @IBOutlet weak var starsPicker: UIPickerView!
    
    var pickerData: [String] = [String]()
    var starsData: [Int: String] = [Int: String]()
    var guildsData: [String] = [String]()
    var ref: DatabaseReference!
    var refShip = DatabaseReference()
    var ships = [Ship]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guildArray = []
        
        transitioningDelegate = self
        
        refShip = Database.database().reference().child("ships")
        playersText.textColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        backBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        
        searchBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        searchBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 15
       let urlShips = "https://swgoh.gg/api/ships.json"
        
        Alamofire.request(urlShips).responseJSON { response in
            let json = response.data
            
            do{
                let decoder = JSONDecoder()
                
                self.ships = try decoder.decode([Ship].self, from: json!)
                
                for ship in self.ships{
                    shipsArray.append(ship.name!)
                }
            }catch let err{
                print(err)
            }
            self.pickerData = shipsArray
            chosenShip = shipsArray[0]
            self.shipPicker.dataSource = self
            self.shipPicker.delegate = self
        }
        
            refShip.observeSingleEvent(of: .value) { (snapshot) in
                guildArray = []
                for guild in snapshot.children{
                    
                    let guildName = guild as! DataSnapshot
                    guildArray.append(guildName.key)
                }
                chosenGuild = guildArray[0]
                self.guildsData = guildArray
                print(self.guildsData)
                self.guildPicker.dataSource = self
                self.guildPicker.delegate = self
            }
      
        
        starsData = [1: "⭐️", 2: "⭐️⭐️", 3: "⭐️⭐️⭐️", 4: "⭐️⭐️⭐️⭐️", 5: "⭐️⭐️⭐️⭐️⭐️", 6: "⭐️⭐️⭐️⭐️⭐️⭐️", 7: "⭐️⭐️⭐️⭐️⭐️⭐️⭐️"]
        
        starsPicker.dataSource = self
        starsPicker.delegate = self
        stars = "1"
    }


    
    
    @IBAction func searchBtn(_ sender: Any) {
        playersText.text = ""
        let guild = chosenGuild
        refShip.child("\(guild)").observeSingleEvent(of: .value, with: {
            snapshot in
            var players = [String]()
            for player in snapshot.children {
                players.append((player as AnyObject).key)
            }
            let value = snapshot.value as? NSDictionary
            for player in 0..<players.count{
                let curPlayer = value![players[player]] as! NSDictionary
                let shipNeeded = chosenShip
                let starsNeeded = stars
                if((curPlayer[shipNeeded] != nil) && (curPlayer[shipNeeded] as! String) == starsNeeded){
                    self.playersText.text = self.playersText.text + players[player] + "\n \n"
                }
            }
            print()
        })
}

    
    @IBAction func backBtn(_ sender: Any) {
    dismiss(animated: true, completion: nil)
        
    }
    
}

extension SearchVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case guildPicker:
            return guildArray.count
        case shipPicker:
            return pickerData.count
        default:
            return starsData.count
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        switch pickerView {
        case guildPicker:
            chosenGuild = guildArray[row]
        case shipPicker:
            chosenShip = pickerData[row]
        default:
            stars = "\(row+1)"
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case guildPicker:
            return guildArray[row]
        case shipPicker:
            return pickerData[row]
        default:
            return starsData[row + 1]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch pickerView {
        case guildPicker:
            return NSAttributedString(string: guildArray[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)])
        case shipPicker:
            return NSAttributedString(string: pickerData[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)])
            
        default:
            return NSAttributedString(string: starsData[row+1]!, attributes: nil)
            
        }
        }

}


extension SearchVC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .dismiss)
    }
    
}
