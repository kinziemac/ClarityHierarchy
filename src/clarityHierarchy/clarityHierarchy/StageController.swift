    //
//  StageViewController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-07.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//
import CoreData
import UIKit

//For Stage 1 Page
class StageController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
  
  var stageNumber: Int = 0
  var numberOfStages: Int = 0
  let gamesList = SharedData.StageData.arrayOfGames
  var text: String = "Please enter calming message:"
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
  //declaration of variables on screen
  @IBOutlet weak var TextFieldView: UITextView!
  @IBOutlet weak var VoiceMemosLabel: UIButton!
  @IBOutlet weak var stageTitle: UINavigationItem!
  @IBOutlet weak var prevButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initView()
  }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      let destination = segue.destination as? voiceMemoController
      destination?.stageNumber = self.stageNumber
      destination?.numberOfStages = self.numberOfStages
    }
    
  func initView(){
    self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
    let context = self.appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    
    do{
      let results = try context.fetch(request)
      self.numberOfStages = results.count
      if results.count > 0 {
        for result in results as! [NSManagedObject]{
          if self.stageNumber == result.value(forKey: "stageNumber") as! Int{
            self.text = result.value(forKey: "stageText") as! String
          }
        }
      }
    }
    catch {
      print("error: could not load data")
    }
    
    //Text Field modifications
    //self.text = SharedData.StageData.stage[self.stageNumber-1]
    let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    self.TextFieldView.layer.borderWidth = 0.5
    self.TextFieldView.layer.borderColor = borderColor.cgColor
    self.TextFieldView.layer.cornerRadius = 5.0
    self.TextFieldView.delegate = self
    self.TextFieldView.text = self.text
    
    //VoiceMemos Label modifications
    self.VoiceMemosLabel.layer.cornerRadius = 10.0
    
    //Stage Name
    self.stageTitle.title = "Stage "+String(self.stageNumber)
    
    
    //display options for buttons
    if( self.stageNumber == 1 ){
      self.prevButton.isHidden = true
    } else {
      self.prevButton.isHidden = false
    }
    
    if( self.stageNumber == self.numberOfStages ){
      self.nextButton.isHidden = true
    } else {
      self.nextButton.isHidden = false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //updates and saves text
  func textViewDidChange(_ textView: UITextView) {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    
    do{
      let results = try context.fetch(request)
      self.text = self.TextFieldView.text
      for result in results as! [NSManagedObject]{
        if self.stageNumber == result.value(forKey: "stageNumber") as! Int{
          result.setValue(self.text, forKey: "stageText")
          do{
            try context.save()
            print(result.value(forKey: "stageText") as! String)
          } catch {
            print("error: could not add new user")
          }
        }
      }
    } catch {
      print("error: data was not loaded")
    }
  }
  
  //for placeholder text
  func textViewDidBeginEditing(_ textView: UITextView) {
    if(self.TextFieldView.text == "Please enter calming message:"){
      self.TextFieldView.text = ""
      self.reloadInputViews()
    }
  }
  
  //list array of games
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.gamesList[row]
  }
  
  //how many rows should be created
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.gamesList.count
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  @IBAction func nextStage(_ sender: Any) {
    print(self.stageNumber)
    self.stageNumber = self.stageNumber + 1
    print(self.stageNumber)
    self.initView()
  }
  
  @IBAction func prevStage(_ sender: Any) {
    print(self.stageNumber)
    self.stageNumber = self.stageNumber - 1
    print(self.stageNumber)
    self.initView()
  }
}
