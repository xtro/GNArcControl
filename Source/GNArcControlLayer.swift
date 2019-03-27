//
//  ArcControl.swift
//  ArcControl
//
//  Created by Gabor Nagy on 27/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import UIKit

class GNArcControlLayer: CALayer
{
	@objc dynamic var valuePercent:CGFloat = 0.5
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
	func percent(_ value:CGFloat)
	{
		let oldValue = valuePercent
		valuePercent = value
		
		let a = CABasicAnimation(keyPath: "valuePercent")
        a.fillMode = .forwards
		let calcDuration = abs(value-oldValue)
		a.duration = Double(calcDuration)*1.0
		a.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		a.fromValue = oldValue
		a.toValue = value
		add(a, forKey: "valuePercent")
	}
	
	var arc:GNArc?
	{
		didSet
		{
			setValue(arc, forKey: "_arc")
		}
	}
	var division:Int = 5
	{
		didSet
		{
			setValue(division, forKey: "_division")
		}
	}
	@objc dynamic var color:UIColor = UIColor.gray
		{
		didSet
		{
			setValue(color, forKey: "_color")
		}
	}
	@objc dynamic var tintColor:UIColor = UIColor.white
		{
		didSet
		{
			setValue(tintColor, forKey: "_tintColor")
		}
	}
	deinit {
		setValue(nil, forKey: "_arc")
		setValue(nil, forKey: "_division")
		setValue(nil, forKey: "_color")
		setValue(nil, forKey: "_tintColor")
	}
	internal func add(to arcControl:GNArcControl)
	{
		contentsScale = UIScreen.main.scale
		frame = arcControl.bounds
		division = arcControl.division
		
		arcControl.layer.addSublayer(self)
	}
	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)
	}
}

extension GNArcControlLayer
{
    internal func glow()
    {
        shadowColor = tintColor.cgColor
        shadowOffset = CGSize.zero
        shadowRadius = 10
        shadowOpacity = 0.5
    }
    internal func dropShadow()
    {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 1)
        shadowRadius = 1
        shadowOpacity = 0.25
    }

}
