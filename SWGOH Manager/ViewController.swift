//
//  ViewController.swift
//  SWGOH Manager
//
//  Created by Konstantin Razinkov on 13/11/2018.
//  Copyright © 2018 RaZero01. All rights reserved.
//

import UIKit
import Firebase

import Alamofire
import SwiftyJSON

struct Ship : Codable{
    
    let name: String?
    let image: String?
    
}

struct Players : Codable{
    let ally_code: String?
}

struct Guild : Codable {
    let data: String?
    let players: String?
}

//var Guild: [String: String] = [:]

struct playerShip : Codable{
    var name: String
    var rarity: Int
    var players: String
}

var shipsArray: [String] = []
var playerArray: [String] = []
var playerShips: [playerShip] = []
var guildName: String = ""
//var shipStarPlayer: [String: [Int: String]] = [:[:]]

class ViewController: UIViewController {
    var ref: DatabaseReference!
    var refShip = DatabaseReference()
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var guildIDField: UITextField!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    
    var ships = [Ship]()
    var player = [Players]()
    var guild = [Guild]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refShip = Database.database().reference().child("ships")
        
        
        transitioningDelegate = self
        
        updateBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        backBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        guildIDField.textColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        labelText.textColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        guildIDField.layer.cornerRadius = 15
        updateBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 15
     
        
    }
    
    func getPlayers(urlString: String){
//
        Alamofire.request(urlString, method: .post, parameters: ["":""]).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let responseDict = result as! [String : Any]
                    let guild = responseDict["data"] as! [String: Any]
                    guildName = guild["name"] as! String
                    self.refShip.child("\(guildName)").setValue("")
                    let players = responseDict["players"] as! NSArray
                    for item in 0..<players.count
                    {
                        let dict = players[item] as! NSDictionary
                        var playerData = dict["data"] as! [String:Any]
                        let playerName = playerData["name"] as! String

                        playerArray.append(playerName)
                        let test = players[item] as! NSDictionary
                        let playerUnits = test["units"] as! NSArray
                        
                        for unit in 0..<playerUnits.count{
                            let curUnit = playerUnits[unit] as! NSDictionary
                            let curUnitData = curUnit["data"] as! NSDictionary
                            
                            
                            if (shipsArray.contains(curUnitData["name"] as! String)){
                                let shipName = curUnitData["name"] as! String
                                let shipRarity = curUnitData["rarity"] as! Int
                                self.refShip.child("\(guildName)").child("\(playerName)").child("\(shipName)").setValue("\(shipRarity)")
                            } else {
                                let charName = curUnitData["name"] as! String
                                let charRarity = curUnitData["rarity"] as! Int
                                self.refShip.child("\(guildName)").child("\(playerName)").child("\(charName)").setValue("\(charRarity)")
                            }
                        }
                        
                }
                }
            case .failure(let error):
                print(error)
            }
        }
        updateAlert(title: "Задача выполнена!", message: "Необходим перезапуск системы!")
    }
    
    func updateAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ПЕРЕЗАПУСТИТЬ СИСТЕМЫ", style: .default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
//            exit(-1)
//            guildArray = []
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
   
    
    func getShips(urlShips: String){
        
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
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func json(from object: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    
    @IBAction func updateBtn(_ sender: Any) {
        let guildID: String = guildIDField.text!
        let urlString = "https://swgoh.gg/api/guild/\(guildID)"
        
        
        let urlShips = "https://swgoh.gg/api/ships.json"
        getPlayers(urlString: urlString)
        getShips(urlShips: urlShips)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension ViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDuration: 3.5, animationType: .dismiss )
    }
    
}

