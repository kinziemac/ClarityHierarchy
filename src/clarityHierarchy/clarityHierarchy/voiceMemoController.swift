//
//  voiceMemoController.swift
//  clarityHierarchy
//
//  Created by Daniel Greenwood on 2017-04-02.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import CoreData
import UIKit
import AVFoundation

class voiceMemoController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{

    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
  let appDelegate = UIApplication.shared.delegate as! AppDelegate


    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var fileMan = FileManager.default;
    var recordingFile: URL!
    var alternateFile: URL!
  var stageNumber: Int = 0
  var numberOfStages: Int = 0
  var fileLink: String = ""
  
    override func viewDidLoad() {
      super.viewDidLoad();
      self.view.backgroundColor = hexStringToUIColor(hex: "ebfaeb")
      self.recordButton.layer.cornerRadius = 5.0
      self.playButton.layer.cornerRadius = 5.0
        initSound();
    }
    
    func initSound(){
        /*playButton.isEnabled=false;
        recordButton.isEnabled=true;*/
        
        var path = fileMan.urls(for: .documentDirectory, in: .userDomainMask);
        let currentTime=NSDate().timeIntervalSince1970;
        let filePath="memo"+String(currentTime)+".m4a";
        let filePath2="memo"+String(currentTime)+"a.m4a"
        self.fileLink = filePath
        
        recordingFile=path[0].appendingPathComponent(filePath);
        alternateFile=path[0].appendingPathComponent(filePath2);
        
        if fileMan.fileExists(atPath:recordingFile.path){
            playButton.isEnabled=true;
        }else{
            playButton.isEnabled=false;
        }
        
        //dump(SharedData.StageData.currentStage);
        let recordSettings=[
            AVFormatIDKey:kAudioFormatMPEG4AAC,
            AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey:320000,
            AVNumberOfChannelsKey:2,
            AVSampleRateKey:44100.0] as [String: Any];
        let session=AVAudioSession.sharedInstance();
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord);
        }catch let error as NSError{
            print("Error opening audio session: \(error.localizedDescription)");
        }
        do{
            try audioRecorder=AVAudioRecorder(url:alternateFile,settings:recordSettings as [String: AnyObject]);
            audioRecorder?.prepareToRecord();
        }catch let error as NSError{
            print("Error opening recording session: \(error.localizedDescription)");
        }
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
      
      
        if audioRecorder?.isRecording==false{
            if audioPlayer?.isPlaying==true{
                audioPlayer?.stop();
            }
            playButton.isEnabled=false;
            audioRecorder?.record();
            recordButton.setTitle("Recording", for: .normal)
        }
        else{
            audioRecorder?.stop();
            playButton.isEnabled=true;
            recordButton.setTitle("Record", for: .normal)
            do{
              
              
              let context = self.appDelegate.persistentContainer.viewContext
              let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
              request.returnsObjectsAsFaults = false
              
              do{
                let results = try context.fetch(request)
                self.numberOfStages = results.count
                if results.count > 0 {
                  for result in results as! [NSManagedObject]{
                    if self.stageNumber == result.value(forKey: "stageNumber") as! Int{
                      result.setValue(self.fileLink, forKey: "stageVoiceMemo")
                      do{
                        try context.save()
                      } catch {
                        print("error: could not add voice memo")
                      }
                    }
                    
                  }
                }
              }
              catch {
                print("error: could not load data")
              }

                if fileMan.fileExists(atPath:recordingFile.path){
                    try fileMan.removeItem(at: recordingFile);
                }
                try fileMan.copyItem(at: alternateFile, to: recordingFile);
            }catch let error as NSError{
                print("Error copying recording file to playback file: \(error.localizedDescription)");
            }
        }
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        if audioRecorder?.isRecording==false{
            if audioPlayer?.isPlaying==true{
              self.playButton.setTitle("Play", for: .normal)
                audioPlayer?.stop();
            }else{
                do{
                    try audioPlayer = AVAudioPlayer (contentsOf: (recordingFile.absoluteURL));
                    audioPlayer!.delegate=self;
                    audioPlayer!.prepareToPlay();
                    audioPlayer!.play();
                }catch let error as NSError{
                    print("Error playing audio: \(error.localizedDescription)");
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  
}
