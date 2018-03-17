//
//  HierarchyMainMenuController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-04-04.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class HierarchyMainMenuController: UIViewController {
  @IBOutlet weak var hierarchyTitle: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var instructionsButton: UIButton!
  

    override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      self.startButton.layer.cornerRadius = 5.0
      self.instructionsButton.layer.cornerRadius = 5.0
      self.editButton.layer.cornerRadius = 5.0
      self.hierarchyTitle.layer.cornerRadius = 5.0
      self.hierarchyTitle.layer.masksToBounds = true
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? HierarchyStageController{
        destination.stageNumber = 1
      }
    }
 

}
