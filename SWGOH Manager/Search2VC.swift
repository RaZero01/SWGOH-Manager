//
//  Search2VC.swift
//  SWGOH Manager
//
//  Created by Konstantin Razinkov on 25/11/2018.
//  Copyright © 2018 RaZero01. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

var charactersArray2: [String] = []
var guildArray: [String] = []
var chosenGuild2 = ""
var chosenCharacter = ""
var rarity = ""
class Search2VC: UIViewController {
    @IBOutlet weak var guildPicker: UIPickerView!
    @IBOutlet weak var characterPicker: UIPickerView!
    @IBOutlet weak var rarityPicker: UIPickerView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var playerShow: UITextView!
    @IBOutlet weak var backBtn: UIButton!
    
    var ref: DatabaseReference!
    var refChar = DatabaseReference()
    var guildData: [String] = [String]()
    var rarityData: [Int: String] = [Int: String]()
    var characterData: [String] = [String]()
    var character = [Character]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guildArray = []
        
        transitioningDelegate = self
        
        refChar = Database.database().reference().child("ships")
        
        playerShow.textColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        searchBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        backBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        searchBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 15
        
        let urlCharacters = "https://swgoh.gg/api/characters.json"
        
        Alamofire.request(urlCharacters).responseJSON { response in
            let json = response.data
            
            
            do{
                let decoder = JSONDecoder()
                
                self.character = try decoder.decode([Character].self, from: json!)
                
                for curCharacter in self.character{
                    charactersArray2.append(curCharacter.name!)
                }
            }catch let err{
                print(err)
            }
            self.characterData = charactersArray2
            chosenCharacter = charactersArray2[0]
            self.characterPicker.dataSource = self
            self.characterPicker.delegate = self
        }
        
        refChar.observeSingleEvent(of: .value) { (snapshot) in
            guildArray = []
            for guild in snapshot.children{
                let guildName = guild as! DataSnapshot
                guildArray.append(guildName.key)
            }
            chosenGuild2 = guildArray[0]
            self.guildData = guildArray
            print(guildArray)
            self.guildPicker.dataSource = self
            self.guildPicker.delegate = self
        }
        
        rarityData = [1: "⭐️", 2: "⭐️⭐️", 3: "⭐️⭐️⭐️", 4: "⭐️⭐️⭐️⭐️", 5: "⭐️⭐️⭐️⭐️⭐️", 6: "⭐️⭐️⭐️⭐️⭐️⭐️", 7: "⭐️⭐️⭐️⭐️⭐️⭐️⭐️"]
        
        rarityPicker.dataSource = self
        rarityPicker.delegate = self
        rarity = "1"
    }
    
    @IBAction func searchBtn(_ sender: Any) {
        playerShow.text = ""
        let guild = chosenGuild2
        refChar.child("\(guild)").observeSingleEvent(of: .value, with: {
            snapshot in
            var players = [String]()
            for player in snapshot.children {
                players.append((player as AnyObject).key)
            }
            let value = snapshot.value as? NSDictionary
            for player in 0..<players.count{
                let curPlayer = value![players[player]] as! NSDictionary
                let characterNeeded = chosenCharacter
                let rarityNeeded = rarity
                if((curPlayer[characterNeeded] != nil) && (curPlayer[characterNeeded] as! String) == rarityNeeded){
                    self.playerShow.text = self.playerShow.text + players[player] + "\n \n"
                }
            }
            print()
        })
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension Search2VC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case guildPicker:
            return guildArray.count
        case characterPicker:
            return charactersArray.count
        default:
            return rarityData.count
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        switch pickerView {
        case guildPicker:
            chosenGuild2 = guildArray[row]
        case characterPicker:
            chosenCharacter = charactersArray[row]
        default:
            rarity = "\(row+1)"
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case guildPicker:
            return guildArray[row]
        case characterPicker:
            return charactersArray[row]
        default:
            return rarityData[row+1]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch pickerView {
        case guildPicker:
            return NSAttributedString(string: guildArray[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)])
        case characterPicker:
            return NSAttributedString(string: charactersArray[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)])
            
        default:
            return NSAttributedString(string: rarityData[row+1]!, attributes: [NSAttributedString.Key.foregroundColor:UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)])
            
        }
    }
    
}

extension Search2VC: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .dismiss)
    }
    
}
