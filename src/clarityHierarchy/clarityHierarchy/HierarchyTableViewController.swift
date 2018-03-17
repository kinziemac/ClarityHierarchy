//
//  FruitsTableViewController.swift
//  clarityHierarchy
//
//  Created by Mackenzie Higa on 2017-03-07.
//  Copyright © 2017 Mackenzie Higa. All rights reserved.
//

import UIKit
import CoreData

class HierarchyTableViewController: UITableViewController {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //creates add button and back button
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(HierarchyTableViewController.insert))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(HierarchyTableViewController.returnHome))
  }
  
  
  func returnHome(){
    performSegue(withIdentifier: "returnToHome", sender: self)
  }
  
  //inserts stage
  func insert(){
    let context = self.appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    do{
      let results = try context.fetch(request)
      if(results.count>9){
        self.tooManyStages()
      } else {
        let newStage = NSEntityDescription.insertNewObject(forEntityName: "Stage", into: context)
        newStage.setValue(results.count+1, forKey: "stageNumber")
        newStage.setValue( "Please enter calming message:", forKey: "stageText")
        newStage.setValue( "", forKey: "stageVoiceMemo")
        do{
          try context.save()
          self.tableView.reloadData()
        } catch {
          print("error: could not add new user")
        }
      }
    } catch {
      print("error: could not load Core data")
    }
  }
  
  //if stages >= 10
  func tooManyStages(){
    let alert = UIAlertController(title: "Warning", message: "You can only create a max of 10 stages", preferredStyle: UIAlertControllerStyle.alert)
    
    
    alert.addAction(UIAlertAction(title: "Done", style: .default) { (action) in
      alert.dismiss(animated: true, completion: nil)
    })
    self.present(alert, animated: true, completion: nil)
  }
  
  //deletes a stage
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let context = self.appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
      request.returnsObjectsAsFaults = false
      var deletingIndex = Int(indexPath.row)+1
      do{
        let results = try context.fetch(request)
        for result in results as! [NSManagedObject]{
          
          if deletingIndex == result.value(forKey: "stageNumber") as! Int{
            context.delete(result)
          }
        }
        
        deletingIndex = deletingIndex + 1
        for result in results as! [NSManagedObject]{
          if deletingIndex == result.value(forKey: "stageNumber") as! Int{
            result.setValue((deletingIndex - 1), forKey: "stageNumber")
            deletingIndex = deletingIndex + 1
          }
        }
        
      } catch {
        print("failed to load data")
      }
      
      
      do{
          try context.save()
          print("deleted")
        } catch {
          print("error: could not add new user")
        }
    }
      self.tableView.reloadData()
      //tableView.deleteRows(at: [indexPath], with: .fade)
  }
  
  //required function
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //sets the number of sections
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  //returns how many stages should appear
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let context = self.appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Stage")
    request.returnsObjectsAsFaults = false
    do{
      let results = try context.fetch(request)
      return results.count
    } catch {
      print("could not return count")
      return 0
    }
  }

  //sets up stages to be rendered by application
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
    cell.textLabel?.text = "Stage " + String(indexPath.row+1)
    return cell
  }
  
  //displays Stages: in top bar
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Stages:"
  }
  
  //passes the stage number to StagePage
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? StageController{
      let indexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
      destination.stageNumber = indexPath.row+1
    }
  }
}





