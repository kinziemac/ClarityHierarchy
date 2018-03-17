//
//  MathQuestionController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-26.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit
import CoreData

class MathQuestionController: UIViewController {
  var mathMode: String = ""
  var seconds = 30
  var answer = 0
  var userAnswer = 0
  var highScore: Int = 0
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var answerInput: UITextField!
  var timer = Timer()
  @IBOutlet weak var backButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
    self.timerLabel.layer.cornerRadius = 5.0
    self.timerLabel.layer.masksToBounds = true
    
    self.questionLabel.layer.cornerRadius = 5.0
    self.questionLabel.layer.masksToBounds = true
    self.submitButton.layer.cornerRadius = 5.0
    
    self.timerLabel.text = String(self.seconds)
    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MathQuestionController.checkTime), userInfo: nil, repeats: true)
    self.setQuestionNumbers()
    self.scoreLabel.text = "0"
    self.answerInput.keyboardType = UIKeyboardType.numberPad
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func checkTime(){
    self.seconds -= 1
    self.timerLabel.text = String(self.seconds)
    if( self.seconds == 0){
      timer.invalidate()
      let alert = UIAlertController(title: "Game Over:", message: "Your score was "+self.scoreLabel!.text!+", Great Job!", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Back to Menu", style: .default) { (action) in
        alert.dismiss(animated: true, completion: nil)
        self.resetGame()
      })
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func resetGame(){
    self.seconds = 30
    self.timerLabel.text = String(self.seconds)
    self.performSegue(withIdentifier: "endGame", sender: self)
  }
  
  func setQuestionNumbers(){
    var negativeNumber = true
    var firstNumber: Int = Int(arc4random_uniform(20)) + 10
    var secondNumber: Int = Int(arc4random_uniform(16)) - Int(arc4random_uniform(12))
    
    while(negativeNumber){
      if( (firstNumber - secondNumber) >= 0){
        negativeNumber = false
      } else {
        firstNumber = Int(arc4random_uniform(20)) + 10
        secondNumber = Int(arc4random_uniform(20)) - Int(arc4random_uniform(12))
      }
    }
    
    var randomInt = -1
    if(self.mathMode == "All"){
      randomInt = Int(arc4random_uniform(3))
    }
    
    if( (self.mathMode == "Addition") || randomInt == 0){
      self.answer = firstNumber + secondNumber
      self.questionLabel.text = String(firstNumber)+" + "+String(secondNumber)
      
    } else if( (self.mathMode == "Subtraction") || randomInt == 1){
      self.answer = firstNumber - secondNumber
      self.questionLabel.text = String(firstNumber)+" - "+String(secondNumber)
      
    } else if( (self.mathMode == "Multiplication") || randomInt == 2){
      firstNumber = Int(arc4random_uniform(12))
      secondNumber = Int(arc4random_uniform(12))
      self.answer = firstNumber * secondNumber
      self.questionLabel.text = String(firstNumber)+" x "+String(secondNumber)
    } else {
      self.performSegue(withIdentifier: "endGame", sender: self)
    }
  }
  
  @IBAction func submitAnswer(_ sender: Any) {
    if(self.answerInput.text! == ""){
      self.userAnswer = 0
    } else {
      self.userAnswer = Int(self.answerInput.text!)!
    }
  
    if(self.userAnswer == self.answer){
      let newScore = Int(self.scoreLabel.text!)! + 5
      print(String(newScore))
      self.scoreLabel.text = String(newScore)
      self.setQuestionNumbers()
    } else {
      self.setQuestionNumbers()
    }
    self.answerInput.text = ""
  }
  

}
