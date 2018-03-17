//
//  ViewController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-06.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit
import CoreData

class MainMenuViewController: UIViewController {
    //Menu Buttons
    @IBOutlet weak var gamesButton: UIButton!
    @IBOutlet weak var hierarchyButton: UIButton!
    @IBOutlet weak var discussionButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //background color
        self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")

        //customizing button style
        self.gamesButton.layer.cornerRadius = 5.0
        self.hierarchyButton.layer.cornerRadius = 5.0
        self.discussionButton.layer.cornerRadius = 5.0
        self.settingsButton.layer.cornerRadius = 5.0
        
        self.navigationItem.hidesBackButton = true
        self.checkFirstTime()
    }
  
  func checkFirstTime(){
    
    //initialize stages
    let context = self.appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    do{
      let results = try context.fetch(request)
      if (results.count) == 0 {
        for i in 0 ..< 3 {
          let newStage = NSEntityDescription.insertNewObject(forEntityName: "Stage", into: context)
          newStage.setValue(i+1, forKey: "stageNumber")
          newStage.setValue( "Please enter calming message:", forKey: "stageText")
          newStage.setValue( "", forKey: "stageVoiceMemo")
              do{
                try context.save()
              } catch {
                print("error: could not add new user")
              }
        }
        
        //initialize highscores
        let newRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Hierarchy")
        newRequest.returnsObjectsAsFaults = false
        do{
          let newScore = NSEntityDescription.insertNewObject(forEntityName: "Hierarchy", into: context)
            newScore.setValue( 0, forKey: "stage1")
            newScore.setValue( 0, forKey: "stage2")
            newScore.setValue( 0, forKey: "stage3")
            newScore.setValue( 0, forKey: "stage4")
            newScore.setValue( 0, forKey: "stage5")
            newScore.setValue( 0, forKey: "stage6")
            newScore.setValue( 0, forKey: "stage7")
            newScore.setValue( 0, forKey: "stage8")
            newScore.setValue( 0, forKey: "stage9")
            newScore.setValue( 0, forKey: "stage10")
          newScore.setValue( 1, forKey: "id")
          do{
            try context.save()
          } catch {
            print("error: could not initialize scores")
          }
          
        } catch {
          print("error: highscore data didn't load")
        }
      }
    } catch {
      print("could not do default initialization")
    }

    
  }
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Main Menu"
    }
    


}

