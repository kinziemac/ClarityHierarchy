//
//  HierarchyStageController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-04-04.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class HierarchyStageController: UIViewController, AVAudioPlayerDelegate {
  
  //variables
  @IBOutlet weak var stageTitle: UILabel!
  @IBOutlet weak var textMemo: UILabel!
  @IBOutlet weak var gameButton: UIButton!
  @IBOutlet weak var voiceMemo: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var prevButton: UIButton!
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var stageNumber: Int = 0
  var numberOfStages: Int = 0
  var audioPlayer: AVAudioPlayer?
  var fileMan = FileManager.default;
  var recordingFile: URL!
  var recordingString: String = ""
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      self.textMemo.layer.cornerRadius = 5.0
      self.textMemo.layer.masksToBounds = true
      
      self.gameButton.layer.cornerRadius = 5.0
      self.gameButton.layer.masksToBounds = true
      
      self.voiceMemo.layer.cornerRadius = 5.0
      self.voiceMemo.layer.masksToBounds = true
      
      self.initView()
    }
  
  func initView(){
    self.stageTitle.text = "Stage "+String(self.stageNumber)
    if(self.stageNumber==1){
      self.prevButton.isHidden = true
    } else {
      self.prevButton.isHidden = false
    }
    
    let context = self.appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    
    do{
      let results = try context.fetch(request)
      self.numberOfStages = results.count
      if( self.stageNumber == self.numberOfStages ){
        self.nextButton.isHidden = true
      } else {
        self.nextButton.isHidden = false
      }
      
      
      for result in results as! [NSManagedObject]{
        if (self.stageNumber == result.value(forKey: "stageNumber") as! Int){
          self.textMemo.text = result.value(forKey: "stageText") as! String!
          self.recordingString = result.value(forKey: "stageVoiceMemo") as! String!
        }
      }
    } catch {
      print("could not load data")
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  @IBAction func toggleAudio(_ sender: Any) {
    var path = self.fileMan.urls(for: .documentDirectory, in: .userDomainMask)
    self.recordingFile = path[0].appendingPathComponent(self.recordingString)
    if audioPlayer?.isPlaying==true{
      self.voiceMemo.setTitle("Play", for: .normal)
      audioPlayer?.stop();
      //playstop
    }else{
      do{
        //turn stage audio string into URL
        try audioPlayer = AVAudioPlayer (contentsOf: (recordingFile.absoluteURL));
        audioPlayer!.delegate=self;
        audioPlayer!.prepareToPlay();
        audioPlayer!.play();
        //playstart
      }catch let error as NSError{
        print("Error playing audio: \(error.localizedDescription)");
      }
    }

    
    
  }
  
  @IBAction func goNext(_ sender: Any) {
        self.stageNumber = self.stageNumber + 1
        self.initView()

  }
  

  @IBAction func goPrev(_ sender: Any) {
        self.stageNumber = self.stageNumber - 1
        self.initView()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? gamesMenuController{
      destination.fromStage = true
      destination.stageNumber = self.stageNumber
    }
    
    if let nextDestination = segue.destination as? MainMenuViewController{
      
      let context = self.appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Hierarchy")
      request.returnsObjectsAsFaults = false
      do{
        let results = try context.fetch(request)
        for result in results as! [NSManagedObject]{
            if (result.value(forKey: "id") as! Int == 1){
              var stage = "stage"+String(describing: self.stageNumber)
              var stageVal = result.value(forKey: stage) as! Int + 1
              result.setValue(stageVal, forKey: stage)
            }
        }
        
        do{
          try context.save()
        } catch {
          print("couldn't save")
        }
        
      } catch{
        print("failure to load")
      }

    }
  }

}
