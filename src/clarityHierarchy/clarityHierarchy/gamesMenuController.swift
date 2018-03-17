//
//  gamesMenuController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-04-04.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class gamesMenuController: UIViewController {
  
  @IBOutlet weak var gameTitle: UILabel!
  @IBOutlet weak var mathButton: UIButton!
  
  @IBOutlet weak var ufoButton: UIButton!
  @IBOutlet weak var tileButton: UIButton!
  
  @IBOutlet weak var cashButton: UIButton!
  var fromStage: Bool = false
  var stageNumber: Int = -1

    override func viewDidLoad() {
      super.viewDidLoad()
      
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      self.gameTitle.layer.cornerRadius = 5.0
      self.gameTitle.layer.masksToBounds = true

      
      self.mathButton.layer.cornerRadius = 5.0
      self.mathButton.layer.masksToBounds = true
      
      self.ufoButton.layer.cornerRadius = 5.0
      self.ufoButton.layer.masksToBounds = true
      
      self.tileButton.layer.cornerRadius = 5.0
      self.tileButton.layer.masksToBounds = true
      
      self.cashButton.layer.cornerRadius = 5.0
      self.cashButton.layer.masksToBounds = true


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func returnToMenu(_ sender: Any) {
    if(!self.fromStage){
    self.performSegue(withIdentifier: "endGame", sender: self)
    } else {
      self.performSegue(withIdentifier: "toHierarchy", sender: self)
    }
  }

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      //HierarchyStageController
      if let destination = segue.destination as? HierarchyStageController{
        destination.stageNumber = self.stageNumber
      }

    }
 

}
