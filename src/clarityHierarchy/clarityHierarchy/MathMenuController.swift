//
//  MathMenuController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-11.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class MathMenuController: UIViewController {

    //variables
    @IBOutlet weak var mathMainMenu: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var instructionsButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      self.mathMainMenu.layer.cornerRadius = 5.0
      self.mathMainMenu.layer.masksToBounds = true
      self.playButton.layer.cornerRadius = 5.0
      self.instructionsButton.layer.cornerRadius = 5.0
    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func instructionsAlert(_ sender: Any) {
    let alert = UIAlertController(title: "Instructions:", message: "Solve the math questions as fast as you can in 60 seconds. Once you have entered an answer in the textbox, click the submit button below. You gain 1 point for every correct answer. There are 4 modes: Addition, Subtraction, Multiplication and All. The 'All' mode consists of a random assortment of the 3 modes together.", preferredStyle: UIAlertControllerStyle.alert)
    
    
    alert.addAction(UIAlertAction(title: "Done", style: .default) { (action) in
      alert.dismiss(animated: true, completion: nil)
    })
    self.present(alert, animated: true, completion: nil)
  }
}
