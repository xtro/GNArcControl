//
//  ArcControl.swift
//  ArcControl
//
//  Created by Gabor Nagy on 27/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import UIKit

extension CALayer
{

	public func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, radiusY r2: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool, position:CGPoint? = nil){
		let l = str.count
		let attributes = [NSAttributedString.Key.font: font]
		let characters: [String] = str.map { String($0) }
		var arcs: [CGFloat] = []
		var totalArc: CGFloat = 0
		for i in 0 ..< l {
            let w = characters[i].size(withAttributes: attributes).width
            arcs += [2 * asin((w) / (2 * r))]
			totalArc += arcs[i]
		}
		let direction: CGFloat = clockwise ? -1 : 1
		let slantCorrection = clockwise ? -CGFloat(Double.pi*0.5) : CGFloat(Double.pi*0.5)
		var thetaI = theta - direction * totalArc / 2
		for i in 0 ..< l {
			thetaI += direction * arcs[i] / 2
			centre(text: characters[i], context: context, radius: r, radiusY: r2, angle: thetaI, colour: c, font: font, slantAngle: thetaI + slantCorrection, position: position)
			thetaI += direction * arcs[i] / 2
		}
	}
	public func centre(text str: String, context: CGContext, radius rX:CGFloat, radiusY rY:CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat, position:CGPoint? = nil) {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let attributes = [NSAttributedString.Key.foregroundColor: c,
						  NSAttributedString.Key.paragraphStyle: paragraphStyle,
						  NSAttributedString.Key.font: font]
		context.saveGState()
		context.scaleBy(x: 1, y: -1)
		if let p = position
		{
			context.translateBy(x: p.x, y: p.y)
		}else{
			context.translateBy(x: rX * cos(theta), y: -(rY * sin(theta)))
		}
		context.rotate(by: -slantAngle)
		let offset = str.size(withAttributes: attributes)
		context.translateBy (x: -offset.width*0.5, y: -offset.height*0.5)
		str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
		context.restoreGState()
	}
}
