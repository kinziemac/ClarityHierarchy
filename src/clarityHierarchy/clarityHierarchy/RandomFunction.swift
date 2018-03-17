//
//  RandomFunction.swift
//  UFO
//
//  Created by Xiaoyong Xu on 2017-03-15.
//  Copyright © 2017 Xiaoyong Xu. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{// The random function for set the rocks' and stars' positions randomly
    
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}

