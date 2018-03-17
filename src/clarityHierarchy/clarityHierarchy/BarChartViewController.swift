//
//  ViewController.swift
//  BarChart
//
//  Created by Xiaoyong Xu on 2017-04-02.
//  Copyright © 2017 Xiaoyong Xu. All rights reserved.
//

import UIKit
import CoreData
// a class of CollectionViewController to create the cell for the barChart
class BarChartViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    var num = [1,2,3,4,5,6,7,8,9,10]
    let cellId = " cellId"
    
    // Create a back button to go back to the MainMenuViewController
    func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
/*Unit testing, we change the value and see if the bar Chart can work correctly, but it falls once we set all the values to 0, becaue the Height has a calculation of the division of Zero and we fixed it by make another condition*/
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  
  
    var values:[CGFloat] = [1,2,3,4,5,6,7,8,9,10]//the value for each bar
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let context = self.appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Hierarchy")
      request.returnsObjectsAsFaults = false
      var counter = 0;
      do{
        let results = try context.fetch(request)
        for result in results as! [NSManagedObject]{
          for i in 0..<10{
            if (result.value(forKey: "id") as! Int == 1){
              var stage = "stage"+String(describing: counter+1)
              values[counter] = CGFloat(result.value(forKey: stage) as! Int)
              counter = counter + 1
            }
          }
          
        }
        
      } catch{
        print("failure to load")
      }
      
        
        //Create the Back button
        let btn: UIButton = UIButton(frame: CGRect(x: 0, y: 0 , width: 50, height: 50))
        btn.backgroundColor = UIColor.white
        btn.setTitle("Back", for:.normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        btn.tag = 1
        self.view.addSubview(btn)
        
        //Unit test for the button
  /*     func action(sender:UIButton!) {
            print("Button Clicked")
        }*/
        
        
        //Register the barCell
        collectionView?.backgroundColor = .white
        collectionView?.register(BarCell.self, forCellWithReuseIdentifier: cellId)
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        
        //Create a Stack View to hold the stage label for autolayout
        let horizontalStackView = UIStackView()
        horizontalStackView.spacing = 15
        horizontalStackView.axis = UILayoutConstraintAxis.horizontal

        //create 10 stage label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label.center = CGPoint(x: 30, y: 640)
        label.textAlignment = .center
        label.text = "st1"
     
        let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label2.center = CGPoint(x: 65, y: 640)
        label2.textAlignment = .center
        label2.text = "st2"

        let label3 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label3.center = CGPoint(x: 100, y: 640)
        label3.textAlignment = .center
        label3.text = "st3"

        let label4 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label4.center = CGPoint(x: 135, y: 640)
        label4.textAlignment = .center
        label4.text = "st4"

        let label5 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label5.center = CGPoint(x: 170, y: 640)
        label5.textAlignment = .center
        label5.text = "st5"

        
        let label6 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label6.center = CGPoint(x: 205, y: 640)
        label6.textAlignment = .center
        label6.text = "st6"

        
        let label7 = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label7.center = CGPoint(x: 240, y: 640)
        label7.textAlignment = .center
        label7.text = "st7"

        
        let label8 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label8.center = CGPoint(x: 275, y: 640)
        label8.textAlignment = .center
        label8.text = "st8"

        
        let label9 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label9.center = CGPoint(x: 310, y: 640)
        label9.textAlignment = .center
        label9.text = "st9"

        
        let label10 = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        label10.center = CGPoint(x: 345, y: 640)
        label10.textAlignment = .center
        label10.text = "st10"

        //push the labels to the HorizontalStackView
        horizontalStackView.addArrangedSubview(label)
        horizontalStackView.addArrangedSubview(label2)
        horizontalStackView.addArrangedSubview(label3)
        horizontalStackView.addArrangedSubview(label4)
        horizontalStackView.addArrangedSubview(label5)
        horizontalStackView.addArrangedSubview(label6)
        horizontalStackView.addArrangedSubview(label7)
        horizontalStackView.addArrangedSubview(label8)
        horizontalStackView.addArrangedSubview(label9)
        horizontalStackView.addArrangedSubview(label10)
        
        self.view.addSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false;
        horizontalStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        NSLayoutConstraint(item: horizontalStackView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leadingMargin, multiplier: 0.5, constant: 10.0).isActive = true

    }
    //set the minimum spacing between the bars
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    //Total number of the bars
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return 10
    }
    //Set the bar length
    func maxHeight() -> CGFloat{
        return view.frame.height - 20 - 54 - 8
    }
    //Create the bar Chart
    override func collectionView(_ collectionView: UICollectionView,  cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as!BarCell
        
        cell.number = [num[indexPath.item]]
        if let max = values.max(){
            let value = values[indexPath.item]
            if max > 0 {//The condition for max value >0
                let ratio = value / max
                cell.barHeightConstraint?.constant = maxHeight() * ratio
            }
            else if max == 0{//The condition for max value = 0

                cell.barHeightConstraint?.constant = 0
            }
        }
        return cell
    }
    
        
    
    //Set the bars' width and height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 25, height: maxHeight())
    }

    //Set the boundary on left and right
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
    }


}


