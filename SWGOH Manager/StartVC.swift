//
//  StartVC.swift
//  SWGOH Manager
//
//  Created by Konstantin Razinkov on 20/11/2018.
//  Copyright © 2018 RaZero01. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Character : Codable {
    let name: String?
    let image: String?
}


var charactersArray: [String] = []
var urlArray: [String] = []
var shipsArray2: [String] = []
class StartVC: UIViewController {
    @IBOutlet weak var searchShipBtn: UIButton!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var searchCharacterBtn: UIButton!
    
    let urlCharacters = "https://swgoh.gg/api/characters.json"
    let urlShips = "https://swgoh.gg/api/ships.json"
    var currentIndex = -1
    
    var characters = [Character]()
    var urls = [Character]()
    
    var ships2 = [Ship]()
    override func viewDidLoad() {
        super.viewDidLoad()

//        transitioningDelegate = self

       
        searchShipBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        characterName.textColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        
        searchCharacterBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        
        updateBtn.backgroundColor = UIColor(red: 229/255, green: 177/255, blue: 58/255, alpha: 1)
        searchCharacterBtn.layer.cornerRadius = 15
        updateBtn.layer.cornerRadius = 15
        searchShipBtn.layer.cornerRadius = 15
        
        
        getCharacters(urlCharacters: urlCharacters)
        getShips(urlShips: urlShips)
        
        
    }
    
    
    @IBAction func searchShipBtn(_ sender: Any) {
       
        guard let searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchVC") as? SearchVC else{
            return
        }
        present(searchVC, animated: true, completion: nil)
    }
    
    @IBAction func searchCharacterBtn(_ sender: Any) {
        guard let search2VC = storyboard?.instantiateViewController(withIdentifier: "Search2VC") as? Search2VC else{
        return
        }
        present(search2VC, animated: true, completion: nil)
    }
    
    @IBAction func updateBtn(_ sender: Any) {
        guard let updateVC = storyboard?.instantiateViewController(withIdentifier: "UpdateVC") as? ViewController else{
            return
        }
        present(updateVC, animated: true, completion: nil)
    }
    
    
    func getCharacters(urlCharacters: String){
   
        Alamofire.request(urlCharacters).responseJSON { response in
            let json = response.data
            
            
            do{
                let decoder = JSONDecoder()
                
                self.characters = try decoder.decode([Character].self, from: json!)
                
                for character in self.characters{
                    charactersArray.append(character.name!)
                    urlArray.append(character.image!)
                }
            }catch let err{
                print(err)
            }
        }
    }
    
    func getShips(urlShips: String){
 
        Alamofire.request(urlShips).responseJSON { response in
            let json = response.data
            
            do{
                let decoder = JSONDecoder()
                
                self.ships2 = try decoder.decode([Ship].self, from: json!)
                
                for ship2 in self.ships2{
                    charactersArray.append(ship2.name!)
                    urlArray.append(ship2.image!)
                    shipsArray2.append(ship2.name!)
                }
            }catch let err{
                print(err)
            }
            self.showNextWord()
        }
    }
    
    
    func showNextWord() {
            currentIndex = Int.random(in: 0..<charactersArray.count)
        
        UIView.animate(withDuration: 1, delay: 1, options: UIView.AnimationOptions(rawValue: 0), animations: { () -> Void in
            self.characterName.alpha = 0.0
            self.characterImage.alpha = 0.0
        }) { (_) -> Void in
            self.characterName.text = charactersArray[self.currentIndex]
            let url = URL(string: "https:\(urlArray[self.currentIndex])")
            let data = try? Data(contentsOf: url!)
            self.characterImage.image = UIImage(data: data!)
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.characterName.alpha = 1.0
                self.characterImage.alpha = 1.0
            }, completion: { (_) -> Void in
                self.showNextWord()
            })
        }
        
    }

}

