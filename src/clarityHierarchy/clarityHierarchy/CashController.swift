
import UIKit
import Darwin
import AVFoundation
import Foundation

class CashController: UIViewController {
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var time:Double = 30
    var score:Int = 0
    var timer = Timer()
    var audioPlayer:AVAudioPlayer!
    var buttonArray = [UIButton]()
    
    
    
    //function to play a sound
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
    
    //delays execution
    func delay(_ delay:Double, closure:@escaping ()->())
    {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    //updates the timer and generates (potentially) an object
    func update()
    {
        if ( time > 0.01 )
        {
            time -= 0.1
            
            //displays double up to two decimal points
            timeLabel.text = "\(abs(round(time*1000)/1000))"
            
            //decides which button to potentially change
            let randomButton = Int(arc4random_uniform(9))
            
            //ABORT if current button isn't blank
            
            if (buttonArray[randomButton].currentImage == #imageLiteral(resourceName: "whiteSquare"))
            {
                //NOTE: A white square is used rather than a hidden image due to
                //auto layout constraint issues
                
                var randomChance = Int(arc4random_uniform(99))
                
                //20% chance of an object appearing
                if (randomChance >= 0 && randomChance < 20 )
                {
                    buttonArray[randomButton].isUserInteractionEnabled = true
                    randomChance = Int(arc4random_uniform(99))
                    let bombOrTime = Int(arc4random_uniform(2))
                    let displayLength = Int(arc4random_uniform(75) + 75)

                    
                    //85% chance of the object being a coin
                    if (randomChance >= 0 && randomChance < 85 )
                    {
                        buttonArray[randomButton].setImage(#imageLiteral(resourceName: "cash"), for: .normal)
                        delay(Double(displayLength)/100.0)
                        {
                            self.buttonArray[randomButton].setImage(#imageLiteral(resourceName: "whiteSquare"), for: .normal)
                            self.buttonArray[randomButton].isUserInteractionEnabled = false
                        }
                    }
                        
                    else
                    {
                        if (bombOrTime == 0)
                        {
                            buttonArray[randomButton].setImage(#imageLiteral(resourceName: "bomb"), for: .normal)
                            delay(Double(displayLength)/100.0)
                            {
                                self.buttonArray[randomButton].setImage(#imageLiteral(resourceName: "whiteSquare"), for: .normal)
                                self.buttonArray[randomButton].isUserInteractionEnabled = false

                            }
                        }
                        else
                        {
                            buttonArray[randomButton].setImage(#imageLiteral(resourceName: "hourglass"), for: .normal)
                            delay(Double(displayLength)/100.0)
                            {
                                self.buttonArray[randomButton].setImage(#imageLiteral(resourceName: "whiteSquare"), for: .normal)
                                self.buttonArray[randomButton].isUserInteractionEnabled = false

                            }
                        }
                    }
                }
            }

        }
        
        //Ends the game when time reaches 0
        else
        {
            timer.invalidate()
            retryButton.setTitleColor(UIColor.black, for: .normal)
            retryButton.layer.borderColor = UIColor.black.cgColor
        }
        

    }
    
    //buttons and their respective actions
    func buttonAction(sender: UIButton)
    {
        if sender.currentImage == #imageLiteral(resourceName: "cash")
        {
            playSound(fileName: "kaching")
            score += 1
        }
        else if sender.currentImage == #imageLiteral(resourceName: "hourglass")
        {
            playSound(fileName: "time")
            time += 3
        }
        else if sender.currentImage == #imageLiteral(resourceName: "bomb")
        {
            playSound(fileName: "boom")
            if (time - 5 < 0)
            {
                time = 0
                timeLabel.text = ("\(time)")
            }
            else
            {
                time -= 5
            }
        }
        
        
        sender.setImage(#imageLiteral(resourceName: "whiteSquare"), for: .normal)
        sender.isUserInteractionEnabled = false
        scoreLabel.text = "\(score)"
 
    }
    
    
    @IBAction func returnToMenu(_ sender: Any)
    {
        //add code here
    }
    
    //starts the timer and changes score back to 0
    @IBAction func restartGame(_ sender: Any)
    {
        retryButton.setTitleColor(UIColor.white, for: .normal)
        retryButton.layer.borderColor = UIColor.white.cgColor
        score = 0
        time = 30
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(CashController.update), userInfo: nil, repeats: true)
    }
    
    //creates basic button
    func createButton(width: Int, height: Int) -> UIButton
    {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.white
        button.setImage(#imageLiteral(resourceName: "whiteSquare"), for: .normal)
        button.isUserInteractionEnabled = false

        
        
        return button
        
    }
    
    //adds buttons to the view
    func printButtons()
    {
        //initializes a vertical stackview for the final allignment
        let matrixStackView = UIStackView()
        matrixStackView.axis  = UILayoutConstraintAxis.vertical
        matrixStackView.spacing = 55
        
        for _ in 0..<3
        {
            //initalizes one of many horizontal stackviews
            let rowStackView   = UIStackView()
            rowStackView.axis  = UILayoutConstraintAxis.horizontal
            rowStackView.spacing = 40
            
            for _ in 0..<3
            {
                let button = createButton(width: 50, height: 50)
                rowStackView.addArrangedSubview(button)
                
                
                
                //makes the tile 50x50 pt size
                button.heightAnchor.constraint(equalToConstant: 50).isActive = true
                button.widthAnchor.constraint(equalToConstant: 50).isActive = true
                buttonArray.append(button)
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

                
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
        matrixStackView.clipsToBounds = false
        
        
        
        
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //first sound is a silent sound to prevent lag from further sounds
        playSound(fileName: "silence")
        
        printButtons()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(CashController.update), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}


