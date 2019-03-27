//
//  Arc.swift
//  ArcControl
//
//  Created by Gabor Nagy on 29/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import Foundation
import UIKit

struct GNRange {
    
    var minimumValue:CGFloat
    var maximumValue:CGFloat
    var value:CGFloat
    
    init(minimum:CGFloat = 0.0,maximum:CGFloat = 1.0,value:CGFloat = 0.0)
    {
        minimumValue = minimum
        maximumValue = maximum
        self.value = value
    }
    var valuePercent:CGFloat{
        get{
            return (value-minimumValue)/(maximumValue-minimumValue)
        }
        set(value){
            self.value = minimumValue+value*(maximumValue-minimumValue)
        }
    }

}
