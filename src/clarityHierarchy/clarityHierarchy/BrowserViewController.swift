//
//  BrowserViewController.swift
//  clarityHierarchy
//
//  Created by Daniel Greenwood on 2017-03-21.
//

import UIKit

class BrowserViewController: UIViewController {
  
  @IBOutlet weak var browserWebView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    URLCache.shared.removeAllCachedResponses();
    
    //prevent 64px scrollview margins from appearing
    self.automaticallyAdjustsScrollViewInsets=false;
    
    var url = URL(string: "");
    
    /*check boolean that is true if opened by settings page*/
    if SharedData.discussionBoardData.fromSettingsPage == true{
        url = URL(string: SharedData.discussionBoardData.discussionBoardURL+SharedData.discussionBoardData.discussionBoardAccountURL);
        SharedData.discussionBoardData.fromSettingsPage = false;
    }else{
        url = URL(string: SharedData.discussionBoardData.discussionBoardURL);
    }
    let request = URLRequest(url: url!);
    browserWebView.loadRequest(request);
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
