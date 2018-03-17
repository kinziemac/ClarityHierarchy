//
//  settingsViewController.swift
//  clarityHierarchy
//
//  Created by Daniel Greenwood on 2017-04-03.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController {

    @IBOutlet weak var eraseVoiceMemoButton: UIButton!
    
    @IBOutlet weak var messageBoardAccountButton: UIButton!
    
    @IBOutlet weak var resetURLButton: UIButton!
    
    @IBOutlet weak var confirmURLButton: UIButton!
    
    @IBOutlet weak var messageBoardURLField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the URL entry field text to the current message board URL
        messageBoardURLField.text=SharedData.discussionBoardData.discussionBoardURL;
    }
    
    /* Erase all voice memos*/
    @IBAction func eraseMemoEvent(_ sender: Any) {
        let fileMan = FileManager.default;
        let path = fileMan.urls(for: .documentDirectory, in: .userDomainMask);
        let numStages = SharedData.StageData.numberOfStages;
        for i in 1...numStages{
            let newPath="\(path)"+"memo"+"\(i)"+".m4a";
            if fileMan.fileExists(atPath: newPath){
                do{
                    try fileMan.removeItem(atPath: newPath)
                }catch let error as NSError{
                    print("Error deleting memo: \(error.localizedDescription)");
                }
            }
        }
    }
    
    /*Open the account settings page for the discussion board on button press*/
    @IBAction func openBrowserEvent(_ sender: Any) {
        SharedData.discussionBoardData.fromSettingsPage = true;
    }
    
    /*Confirm change of message board url on button press*/
    @IBAction func confirmURLEvent(_ sender: Any) {
        SharedData.discussionBoardData.discussionBoardURL = messageBoardURLField.text!;
    }
    
    /*Reset message board url to default on button press*/
    @IBAction func resetURLEvent(_ sender: Any) {
        SharedData.discussionBoardData.discussionBoardURL = SharedData.discussionBoardData.discussionBoardDefaultURL;
        messageBoardURLField.text=SharedData.discussionBoardData.discussionBoardDefaultURL;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
