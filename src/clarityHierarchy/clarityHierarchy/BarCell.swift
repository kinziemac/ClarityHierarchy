//
//  BarCell.swift
//  BarChart
//
//  Created by Xiaoyong Xu on 2017-04-02.
//  Copyright © 2017 Xiaoyong Xu. All rights reserved.
//

import UIKit


//Create a cell for Bars
class BarCell: UICollectionViewCell {
    
    var number = [1]
    let barView: UIView = {//Set the bar Cell
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var barHeightConstraint: NSLayoutConstraint?
    
    override var isHighlighted: Bool{// when user touch the bar, the bar will highlight
        didSet {
            barView.backgroundColor = isHighlighted ? .black : .red
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        addSubview(barView)
   //     setupViews()
        
        //Set the Anchor for the bar Chart
        barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: 300)
        barHeightConstraint?.isActive = true
        barHeightConstraint?.constant = 100
        barView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        barView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        barView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
    }
    //Unit test for the label but fail ,so we choose the horizational StackView to add the label
   /*
   let stageNumberView :UILabel = {
        let textView = UILabel()
        let number = [1,2,3,4,5,6,7,8,9,10]
        let n = "st\(number)"
        textView.backgroundColor = UIColor.yellow
        textView.text = n
        return textView
    }()*/
    
/*    let numberView :UITextView = {
        let View = UITextView()
        View.backgroundColor = UIColor.blue
        View.translatesAutoresizingMaskIntoConstraints = false
        return View
    }()
   */
/*    func setupViews(){
        
        addSubview(stageNumberView)
        stageNumberView.frame = CGRect(x:0,y:400,width:50,height:50)
    }
    */
    required init?(coder aDecoder:NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
