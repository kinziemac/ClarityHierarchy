//
//  SharedData.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-07.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import Foundation
import UIKit

//temporary volatile storage in app, will connect to core data in next version
class SharedData {
    struct discussionBoardData{
        //Current URL of Discussion Board
        static var discussionBoardURL = "https://0x64.ca/clarity/"
        //Default URL of Discussion Board
        static var discussionBoardDefaultURL = "https://0x64.ca/clarity/"
        //Account Management URL
        static var discussionBoardAccountURL = "account.php"
        
        //boolean that is true if settings page opens the browser
        static var fromSettingsPage = false;
    }
    struct StageData{
        //lists number of stages
        static var identities = [String]()
        
        //number of stages
        static var numberOfStages = 3
        
        //defaults currentStage
        static var currentStage = 1
        
        //default input text
        static var text = "Enter Text"
        static var placeholderText = "Enter Text"
        
        //games array for games section and stage page
        static var arrayOfGames = ["Math Question", "Racing Game", "Whack-a-mole", "Remember the Pattern", "Line-Swinging"]
        
        //saved text space for stages
        static var stage = ["Enter Text", "Enter Text", "Enter Text", "Enter Text", "Enter Text"]
    }
}

//self explanatory title
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
