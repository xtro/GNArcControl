//
//  Arc.swift
//  ArcControl
//
//  Created by Gabor Nagy on 29/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import UIKit

internal class GNArcControlLabels: GNArcControlLayer
{
	private let stepStrokeWidth:CGFloat = 1.0

	internal var range:GNRange?
	{
		didSet
		{
			setValue(range, forKey: "_range")
		}
	}
	internal var isFlipped:Bool = false
	internal var measure:String = "%"
	{
		didSet
		{
			setValue(measure, forKey: "_measure")
		}
	}

	deinit {
		setValue(nil, forKey: "_range")
		setValue(nil, forKey: "_measure")
	}
	override internal func add(to arcControl:GNArcControl)
	{
		measure = arcControl.measure
		range = arcControl.range
		isFlipped = arcControl.isFlipped
		super.add(to: arcControl)
	}
	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)
		if 	let arc 		= value(forKey: "_arc") as? GNArc,
			let range		= value(forKey: "_range") as? GNRange,
			let division 	= value(forKey: "_division") as? Int,
			let color 		= value(forKey: "_color") as? UIColor,
			let tintColor 	= value(forKey: "_tintColor") as? UIColor,
			let measure 	= value(forKey: "_measure") as? String
		{
			_draw(ctx, arc, range, division, measure, color, tintColor)
		}
		
	}
	internal func _draw(_ context:CGContext, _ arc:GNArc, _ range:GNRange,  _ division:Int,_ measure:String ,_ color:UIColor, _ tintColor:UIColor)
	{
		let offset:CGFloat = 15
		let offsetY:CGFloat = 10
		let size = bounds
		let radius = arc.radius
		context.translateBy (x: size.width / 2, y: radius+offsetY)
		context.scaleBy (x: 1, y: -1)

		var r = GNRange(minimum: range.minimumValue, maximum: range.maximumValue, value: 0)
		for i in 0...division
		{
			let percent = CGFloat(i)/CGFloat(division)
			r.valuePercent = CGFloat(i)/CGFloat(division)
			var newColor:UIColor?
			let centerBased:Bool = (range.minimumValue < 0)
			if(centerBased){
                if percent == 0.5
                {
                    newColor = tintColor
                }else if percent <= 0.5 && percent < 1
                {
                    if(percent >= valuePercent && percent <= 0.5 && percent >= 0){
                        newColor = tintColor
                    }else{
                        newColor = color
                    }
                }else{
                    if(percent <= valuePercent && r.valuePercent >= 0.5){
                        newColor = tintColor
                    }else{
                        newColor = color
                    }
                }
            }else{
                if(percent <= valuePercent){
					newColor = tintColor
				}else{
					newColor = color
				}
			}
			let angle = arc.tickAngle(1-r.valuePercent)-(CGFloat.pi)
			let text = "\(Int(r.value))\(measure)"
			//
			let r1 = bounds.midX-5-offset
			let r2 = bounds.midY+25-offset
			UIGraphicsPushContext(context)
			centreArcPerpendicular(text: text, context: context, radius: r1, radiusY: r2, angle: angle, colour: newColor!, font: UIFont.systemFont(ofSize: 8), clockwise: true)
			UIGraphicsPopContext()
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
