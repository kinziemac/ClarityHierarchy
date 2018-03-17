//
//  ReadyController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-26.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class ReadyController: UIViewController {
  var mathMode: String = "mack"

  @IBOutlet weak var loadingStatusLabel: UILabel!
  
    override func viewDidLoad() {
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      super.viewDidLoad()

      delay(1.5){
        self.updateStatus()
        self.delay(1.0){
          self.toGamePage()
        }
      }
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

  func updateStatus() {
        //present your view controller
      self.loadingStatusLabel.text = "Start!"
    }

  func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
  }

  func toGamePage(){
    performSegue(withIdentifier: "toMathGame", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as? MathQuestionController
    
    destination?.mathMode = self.mathMode
    

  }
  



}




