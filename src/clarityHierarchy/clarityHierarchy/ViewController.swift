//
//  ViewController.swift
//  Tile Match
//
//  Created by Brian Wu on 2017-03-11.
//  Copyright © 2017 Brian Wu. All rights reserved.
//

import UIKit
import Darwin
import AVFoundation
import Foundation

//simple fade in fade out animation
extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

class ViewController: UIViewController {
    
    
    var userWhiteCount:Int = 0
    var answerWhiteCount:Int = 0
    var timeToSolve:Double = 5.0
    var score:Int = 0
    var level:Int = 3
    
    var audioPlayer:AVAudioPlayer!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var levelUpButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    let instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    var correctSequence = [Int]()
    var userSequence = [Int]()
  
    
    
    
    
    func clearScreen(entireScreen: Bool)
    {
        for view in self.view.subviews {
            if view is UIStackView
            {
                view.removeFromSuperview()
            }
        }
        
        if entireScreen == true
        {
            instructionLabel.isHidden = true
            //scoreLabel.isHidden = true
            exitButton.isHidden = true
            levelUpButton.isHidden = true
            doneButton.isHidden = true
        }
        
        
    }
    
    //plays a sound
    func playSound(fileName: String)
    {
        guard let sound = NSDataAsset(name: fileName) else {
            print("asset not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
            
            audioPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    
    
    //Pressed when the user cannot fully remember the puzzle and ends the game
    @IBAction func endGame(_ sender: UIButton)
    {
        clearScreen(entireScreen: true)
        
        scoreLabel.text = "\(score)"
        let endGameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        endGameLabel.translatesAutoresizingMaskIntoConstraints = false
        endGameLabel.text = "Your score was \(score)"
        
        let retryButton = createButton(width:100, height:100, borderWidth: 1)
        retryButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.isHidden = true

        
        let stackView = UIStackView()
        stackView.axis  = UILayoutConstraintAxis.vertical
        stackView.spacing   = 15
        
        stackView.addArrangedSubview(endGameLabel)
        stackView.addArrangedSubview(retryButton)
        
        
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 160).isActive = true
        stackView.fadeOut()
        stackView.fadeIn()
        
        delay(1)
        {
            retryButton.isHidden = false
            retryButton.fadeOut()
            retryButton.fadeIn()
        }
        
    }
    
    
    //Increases the dimension count of the matrix, up to a cap of 5 (6 being too difficult)
    @IBAction func increaseDifficulty(_ sender: UIButton)
    {
        level += 1
        timeToSolve += 1.5
        if (level > 4)
        {
            sender.isHidden = true
        }

        playSound(fileName: "levelup")
    }
    
    //Press to see if your answer is correct
    @IBAction func submitPattern(_ sender: UIButton)
    {
        //must be true for the arrays to be equal
        
        if (compareAnswers() == true)
        {
            
            score += level*level*level
            playSound(fileName: "correct")
            
            //deletes the matrix only
            
            clearScreen(entireScreen: false)
            
            
            correctSequence.removeAll()
            userSequence.removeAll()
            
            //scoreLabel.text = "\(score)"
            
            runGame(difficulty: level)
            
        }
        
        
        //submit an incorrect pattern and lose points
        else
        {
            playSound(fileName:"wrong")
            if score > level
            {
                score -= level
            }
            else
            {
                score = 0
            }
        }
        
    }
    

    
    
    
    
    //implemented own delay function because swift's default delay function cannot
    //work with variable parameters
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    

    //creates a button
    func createButton(width: Int, height: Int, borderWidth: Double) -> UIButton
    {
        let tile = UIButton()
        tile.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tile.layer.borderWidth = CGFloat(borderWidth)
        tile.layer.borderColor = UIColor.gray.cgColor
        tile.setTitleColor(UIColor.black, for: .normal)

        
        return tile
        
    }
    
    
    
    //creates matrix
    //position of tiles relative to one another is irrelevant as it is fixed by auto layout
    func createMatrix(dimensions:Int, userMatrix:Bool) -> [[UIButton]]
    {
        var tileArray = [[UIButton]]()
        var tileSubArray = [UIButton]()
     
        
        
        for rows in 0..<dimensions
        {
            tileSubArray.removeAll()
            for cols in 0..<dimensions
            {
                let tile:UIButton = createButton(width: 50, height: 50, borderWidth: 0.5)
                
                //50% chance of black or white, 0 is white and 1 is black
                let whiteOrBlack = Int(arc4random_uniform(2))
                
                
        
                if (userMatrix == false)
                {
                    if (whiteOrBlack == 0)
                    {
                        answerWhiteCount += 1
                        tile.backgroundColor = UIColor.white
                    }
                    else
                    {
                        tile.backgroundColor = UIColor.black
                    }
                    
                    correctSequence.append(whiteOrBlack)
                    
                
                }
                
                else
                {
                    tile.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                    
                    if (whiteOrBlack == 0)
                    {
                        userWhiteCount += 1
                        tile.backgroundColor = UIColor.white
                    }
                    else
                    {
                        tile.backgroundColor = UIColor.black

                    }
                    
                    //tags the buttons in order to modify the array containing the sequence
                    tile.tag = rows * dimensions + cols
                    userSequence.append(whiteOrBlack)

                }
                
                
                tileSubArray.append(tile)
                

            }
            
            
 
            tileArray.append(tileSubArray)
            

        }
        
        
        
        return tileArray
        
    }
    
    //displays matrix onto superview
    func printMatrix(matrix: [[UIButton]])
    {
        //initializes a vertical stackview for the final allignment
        let matrixStackView = UIStackView()
        matrixStackView.axis  = UILayoutConstraintAxis.vertical
        matrixStackView.spacing  = 0
       
        for rows in 0..<matrix.count
        {
            //initalizes one of many horizontal stackviews
            let rowStackView   = UIStackView()
            rowStackView.axis  = UILayoutConstraintAxis.horizontal
            rowStackView.spacing   = 0
            
            for cols in 0..<matrix.count
            {
                rowStackView.addArrangedSubview(matrix[rows][cols])
                
                //makes the tile 50x50 pt size
                matrix[rows][cols].heightAnchor.constraint(equalToConstant: 50).isActive = true
                matrix[rows][cols].widthAnchor.constraint(equalToConstant: 50).isActive = true
                
            }
            
            //adds a full horizontal stackview into the vertical stackview
            matrixStackView.addArrangedSubview(rowStackView)
            
        }
        
        //displays the stack view of stack views
        self.view.addSubview(matrixStackView)
        
        //allows auto layout modifications
        matrixStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        //dead center
        matrixStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        matrixStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        matrixStackView.fadeOut()
        matrixStackView.fadeIn()

        
        
        
    }
    
    //removes a matrix from the superview
    func deleteMatrix(matrix: [[UIButton]])
    {
        for rows in 0..<matrix.count
        {
            for cols in 0..<matrix.count
            {
                matrix[rows][cols].removeFromSuperview()
            }
            
        }
    }
    
    //checks if two arrays are equal
    func compareAnswers() -> Bool
    {
        if (userWhiteCount == answerWhiteCount)
        {
            for i in 0..<correctSequence.count
            {
                if (correctSequence[i] != userSequence[i])
                {
                    return false
                }
            }
        }
        
        else
        {
            return false
        }
        
        return true
    }
    
    //runs a full round
    func runGame(difficulty: Int)
    {
        scoreLabel.text = "\(score)"
        userSequence.removeAll()
        correctSequence.removeAll()
        userWhiteCount = 0
        answerWhiteCount = 0
        self.exitButton.isHidden = true
        self.doneButton.isHidden = true
        instructionLabel.text = "Memorize the pattern"
        instructionLabel.fadeOut()
        instructionLabel.fadeIn()
        
        let answerArray = createMatrix(dimensions: difficulty, userMatrix: false)
        let userArray = createMatrix(dimensions: difficulty, userMatrix: true)
        
        
        self.printMatrix(matrix: answerArray)
        
        
        delay(timeToSolve)
        {
            self.clearScreen(entireScreen: false)
            self.instructionLabel.fadeOut()
            
            
            self.delay(1.25)
            {
                self.instructionLabel.text = "Recreate the pattern"
                self.instructionLabel.fadeIn(0.5)
                self.printMatrix(matrix: userArray)
                self.exitButton.isHidden = false
                self.doneButton.isHidden = false

            }

        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //There is some lag when the first sound is played. Played silence to get rid of the lag.
        playSound(fileName: "silence")
        
        
        //allows autolayout adjustments on the instruction label
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false;
        instructionLabel.textAlignment = .center
        
        self.view.addSubview(instructionLabel)
        
        //centers the label vertically, and then moves it 130 pts from the top
        instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        NSLayoutConstraint(item: instructionLabel, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 130).isActive = true
        
        //start game
        runGame(difficulty:level)

        
 
    }
    
    
    
    func buttonAction(sender: UIButton)
    {
        if score > 0 { score -= 1 }
        
        playSound(fileName: "click")
        
        
        //changes colors depending on current color
        //modifies count of white tiles 
        //modifies array sequence of tiles
        
        if sender.backgroundColor == UIColor.white
        {
            sender.backgroundColor = UIColor.black
            userSequence[sender.tag] = 1
            userWhiteCount -= 1
            
        }
            
        else
        {
            sender.backgroundColor = UIColor.white
            userSequence[sender.tag] = 0
            userWhiteCount += 1
        }

    }
    
    func resetGame(sender: UIButton)
    {
        score = 0
        timeToSolve = 5.0
        level = 3
        
        userSequence.removeAll()
        correctSequence.removeAll()
        
        clearScreen(entireScreen: true)
        instructionLabel.isHidden = false
        levelUpButton.isHidden = false
        
        runGame(difficulty: level)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

