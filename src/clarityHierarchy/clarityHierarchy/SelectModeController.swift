//
//  SelectModeController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-25.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class SelectModeController: UIViewController {

  //variables
  @IBOutlet weak var additionButton: UIButton!
  
  @IBOutlet weak var subtractionButton: UIButton!
  
  @IBOutlet weak var multiplicationButton: UIButton!
  
  @IBOutlet weak var allButton: UIButton!
  
  @IBOutlet weak var selectModeLabel: UILabel!
  @IBOutlet weak var backButton: UIButton!
  
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      self.selectModeLabel.layer.cornerRadius = 5.0
      self.selectModeLabel.layer.masksToBounds = true
      self.additionButton.layer.cornerRadius = 5.0
      self.subtractionButton.layer.cornerRadius = 5.0
      self.multiplicationButton.layer.cornerRadius = 5.0
      self.allButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as? ReadyController
    
    if let button = sender as? UIButton {
      destination?.mathMode = (button.titleLabel?.text)!
    }
  }
  
}
