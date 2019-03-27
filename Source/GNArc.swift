//
//  Arc.swift
//  ArcControl
//
//  Created by Gabor Nagy on 29/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat
{
    public var radians:CGFloat
    {
        return self * CGFloat(Double.pi/180.0);
    }
}

public class GNArc
{
    internal var bounds:CGRect
    internal var isFlipped:Bool
    internal var isVertical:Bool
    internal var inset:Float

    public init(_ frame:CGRect,vertical:Bool? = true,fliped:Bool? = false, inset:Float? = 20){
        bounds = frame
        isFlipped = fliped!
        isVertical = vertical!
        self.inset = inset!
		
	}
    
    public var radius:CGFloat{
        return (innerBounds.height*0.5) + ( pow(innerBounds.width,2)/(8.0*innerBounds.height) )
    }
    public var center:CGPoint{
        return CGPoint(x: innerBounds.origin.x+(innerBounds.width*0.5), y: innerBounds.origin.y+radius)
    }
    public var angle:CGFloat{
        return acos( innerBounds.width / (2.0*(radius)) )
    }
    public var endAngle:CGFloat{
        return CGFloat((360)).radians - angle
    }
    public var startAngle:CGFloat{
        return CGFloat(180).radians + angle
    }
    public var height:CGFloat{
        return innerBounds.height
    }

    public func tickAngle(_ ratio:CGFloat) -> CGFloat{
        return startAngle+((endAngle-startAngle)*ratio)//
    }
    public var range:CGFloat{
        return endAngle-startAngle
    }
    public var innerBounds:CGRect{
        var frame = self.bounds
        if(isVertical){
            let w = frame.width
            let h = frame.height
            frame.size.width = h;
            frame.size.height = w;
        }
        return frame.insetBy(dx: CGFloat(inset), dy: CGFloat(inset))
    }
    public func calculateAngle(_ point: CGPoint) -> CGFloat
    {
        let arc = GNArc(bounds, vertical: self.isVertical, fliped: isFlipped)
        let originPoint = CGPoint(x: point.x - arc.center.x, y: point.y - arc.center.y)
        let bearingRadians = atan2f(Float(originPoint.y), Float(originPoint.x))
        return CGFloat(bearingRadians)
    }
    public func calculatePercent(_ angle:CGFloat) -> CGFloat
    {
        var percent = ((CGFloat(angle)+CGFloat(Double.pi*0.5))/range)+0.5
        if(percent > 1.0){
            percent = 1.0
        }else if(percent < 0.0){
            percent = 0.0
        }
        return percent
    }
    public func rotateContext(_ context:CGContext)
    {
        if(isVertical){
            let frame = self.bounds
            let h = frame.height

            context.translateBy(x: 0, y: h)
            context.rotate(by: CGFloat(-Double.pi*0.5))
        }
    }
}
