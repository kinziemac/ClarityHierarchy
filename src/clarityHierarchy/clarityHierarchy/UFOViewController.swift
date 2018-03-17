
//  UFOViewController.swift
//  UFO game view controller
//
//  Created by Xiaoyong Xu on 2017-03-15.
//  Copyright © 2017 Xiaoyong Xu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class UFOViewController: UIViewController {
    @IBAction func helppage(_ sender: Any) {//create a button to show the instruction
        let alert = UIAlertController(title: "Instructions:", message: "Start the game by tapping in the screen. Keep tapping and make the UFO travel and avoide collision with the rocks and meteors. Collect the yellow stars to earn points", preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "Got it", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.showsPhysics = true
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                //scene.size = self.view.bounds.size
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            //Unit test for nodeCount
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}



