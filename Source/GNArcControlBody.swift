//
//  ArcControl.swift
//  ArcControl
//
//  Created by Gabor Nagy on 27/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import UIKit

class GNArcControlBody: GNArcControlLayer
{
	var drawHandler:GNArcControlDraw?
	{
		didSet
		{
			setValue(drawHandler, forKey: "_drawHandler")
		}
	}

	private let stepStrokeWidth:CGFloat = 1.0
	
	var subDivision:Int = 1
	{
		didSet
		{
			setValue(subDivision, forKey: "_subDivision")
		}
	}
	var centerBased:Bool = false
	{
		didSet
		{
			setValue(centerBased, forKey: "_centerBased")
		}
	}
	deinit {
		setValue(nil, forKey: "_subDivision")
		setValue(nil, forKey: "_centerBased")
		setValue(nil, forKey: "_drawHandler")
	}
	override internal func add(to arcControl:GNArcControl)
	{
		subDivision = arcControl.subDivision
		super.add(to: arcControl)
	}
	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)
		if 	let arc 		= value(forKey: "_arc") as? GNArc,
			let division 	= value(forKey: "_division") as? Int,
			let subDivision	= value(forKey: "_subDivision") as? Int,
			let color 		= value(forKey: "_color") as? UIColor,
			let tintColor 	= value(forKey: "_tintColor") as? UIColor,
			let centerBased	= value(forKey: "_centerBased") as? Bool
		{
			_draw(ctx, arc, division, subDivision, color, tintColor, centerBased, valuePercent)
		}
		
	}
	internal func _draw(_ context:CGContext, _ arc:GNArc, _ division:Int, _ subDivision:Int, _ color:UIColor, _ tintColor:UIColor, _ centerBased:Bool, _ percent:CGFloat)
	{
		context.setLineWidth(stepStrokeWidth)
		context.setLineCap(.round)
		
		let steps = (division*subDivision)
		for i in 0...steps
		{
			var isSelected:Bool = false
			let ratio = CGFloat(i)/CGFloat(steps+1)
			if centerBased
			{
				if percent < 0.5
				{
					if(ratio >= percent && ratio <= 0.5){
						isSelected = true
					}
				}else{
					if(ratio <= percent && ratio >= 0.5){
						isSelected = true
					}
				}
			}else{
				if(ratio <= percent){
					isSelected = true
				}
			}
            
			let cAngle = cos(arc.tickAngle(ratio))*arc.radius
			let sAngle = sin(arc.tickAngle(ratio))*arc.radius
			let isSubdivision = (i%subDivision == 0) ? false : true
			let p = CGPoint(x: arc.center.x+(cAngle), y: arc.center.y+(sAngle))
			if let d = value(forKey: "_drawHandler") as? GNArcControlDraw
			{
				d(context,p,arc.center,isSelected,isSubdivision)
			}else{
				var newColor:UIColor = color
				if isSelected
				{
					newColor = tintColor
				}
				let radius:CGFloat = isSubdivision ? 0.5 : 2.5
				context.drawCircle(at: p, radius: radius, color: newColor.cgColor)
			}
		}
	}
	override class func needsDisplay(forKey key: String) -> Bool
	{
		if(key == "valuePercent"){
			return true
		}
		return super.needsDisplay(forKey: key)
	}
}

