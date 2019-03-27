//
//  ArcControl.swift
//  ArcControl
//
//  Created by Gabor Nagy on 27/10/15.
//  Copyright © 2015 Shellshaper. All rights reserved.
//

import UIKit

protocol GNArcControlDelegate
{
    func arcControlDidChange(_ control:GNArcControl,value:Float)
}
public typealias GNArcControlDraw = ((_ context:CGContext,_ point:CGPoint,_ center:CGPoint,_ isSelected:Bool,_ isSubdivision:Bool)->Void)
public typealias GNArcControlPoint = ((_ point:CGPoint,_ center:CGPoint)->Void)

public extension CGRect
{
	static func circle(at point:CGPoint, radius:CGFloat) -> CGRect
	{
		return CGRect(x: point.x, y: point.y, width: 0, height: 0).insetBy(dx: -radius, dy: -radius)
	}
}
public extension CGContext
{
	func drawCircle(at point:CGPoint, radius:CGFloat, color:CGColor? = nil)
	{
		if let c = color
		{
			setFillColor(c)
		}
		move(to: point)
		fillEllipse(in: CGRect.circle(at: point, radius: radius))
	}
    func drawSelection(arc:GNArc, angle:CGFloat,radius:CGFloat = 10, color:UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0103, alpha: 1 ),lineWidth:CGFloat = 1.5)
    {
        setLineWidth(lineWidth)
        setLineCap(.round)
        setStrokeColor(color.cgColor)
        
        let point = CGPoint(x: arc.center.x + arc.radius*cos(angle),
                            y: arc.center.y + arc.radius*sin(angle)
                    )
        addEllipse(in: CGRect.circle(at: point, radius: radius))
        strokePath()
        
    }

}


@IBDesignable
final class GNArcControl: UIView {
    fileprivate let strokeWidth:CGFloat = 1.0
    fileprivate var isEditing:Bool = false
    fileprivate var hasMoved:Bool = false
    fileprivate var selectionAngle:CGFloat = 0

    fileprivate let body:GNArcControlBody = GNArcControlBody()
	fileprivate let labels:GNArcControlLabels = GNArcControlLabels()
	fileprivate let selectedBody:GNArcControlBody = GNArcControlBody()
	fileprivate let selectedLabels:GNArcControlLabels = GNArcControlLabels()

    public var range:GNRange = GNRange()
    @IBInspectable public var isFlipped:Bool = false
    @IBInspectable public var isVertical:Bool = true
    @IBInspectable public var hasLabels:Bool = true
    @IBInspectable public var bodyColor:UIColor = UIColor ( red: 0.4681, green: 0.4842, blue: 0.5, alpha: 0.429992242907801 )
    @IBInspectable public var division:Int = 10
	{
		didSet
		{
			labels.division = division
		}
	}
    @IBInspectable public var subDivision:Int = 5
    @IBInspectable public var minimumValue:CGFloat = 0
	{
		didSet
		{
			range.minimumValue = minimumValue
		}
	}
    @IBInspectable public var maximumValue:CGFloat = 100
	{
		didSet
		{
			range.maximumValue = maximumValue
		}
	}
    @IBInspectable public var measure:String = "%"
	{
		didSet
		{
			labels.division = division
		}
	}
    public var value:CGFloat{
        set(value){
            range.value = value
            valueDidChange?(value)
            self.setNeedsDisplay()
        }
        get{
            return range.value
        }
    }
    public var valueDidChange:((CGFloat) -> Void)?
    
    override public func layoutSubviews() {
		let arc = GNArc(bounds, vertical: self.isVertical, fliped: isFlipped)
		body.arc = arc
		body.frame = self.bounds
 		body.setNeedsDisplay()
		labels.arc = arc
		labels.frame = self.bounds
		labels.setNeedsDisplay()
		//
		selectedBody.arc = arc
		selectedBody.frame = self.bounds
		selectedBody.setNeedsDisplay()
		selectedBody.drawHandler = { [weak self] (context,point,center,isSelected,isSubdivision) in
			if isSelected
			{
				let radius:CGFloat = isSubdivision ? 1 : 2
				context.drawCircle(at: point, radius: radius, color: UIColor.white.cgColor)
                if let angle = self?.selectionAngle, let e = self?.isEditing, e
                {
                    //context.drawSelection(arc: arc, angle: angle)
                }
			}
		}
		selectedLabels.arc = arc
		selectedLabels.frame = self.bounds
		selectedLabels.setNeedsDisplay()
        //
        super.layoutSubviews()
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    public override var frame: CGRect
    {
        didSet
        {
            let arc = GNArc(self.bounds, vertical: self.isVertical, fliped: isFlipped)
            body.arc = arc
            labels.arc = arc
        }
    }
    override public func awakeFromNib() {
        if(isFlipped){
            var t = CGAffineTransform(rotationAngle: CGFloat.pi)
            if(isVertical){
                t = t.scaledBy(x: 1, y: -1)
            }else{
                t = t.scaledBy(x: -1, y: 1)
            }
            self.transform = t
        }
		let arc = GNArc(bounds, vertical: self.isVertical, fliped: isFlipped)
		body.color = .lightGray
		body.tintColor = .clear
		body.arc = arc
		body.centerBased = self.minimumValue < 0
		body.add(to: self)
		body.setNeedsDisplay()

		labels.division = division
		labels.measure = measure
		labels.range = range
		labels.arc = arc
		labels.color = .lightGray
		labels.tintColor = .clear
		labels.masksToBounds = false
		labels.add(to: self)
		labels.setNeedsDisplay()
		
		selectedBody.color = .clear
		selectedBody.tintColor = .white
		selectedBody.arc = arc
		selectedBody.centerBased = self.minimumValue < 0
		selectedBody.add(to: self)
		selectedBody.setNeedsDisplay()
		
		selectedLabels.division = division
		selectedLabels.measure = measure
		selectedLabels.range = range
		selectedLabels.arc = arc
		selectedLabels.color = .clear
		selectedLabels.tintColor = .white
		selectedLabels.add(to: self)
		selectedLabels.setNeedsDisplay()
		
        body.dropShadow()
        labels.dropShadow()
		selectedBody.glow()
		selectedLabels.glow()
    }

    // MARK: Calculate angle & value
	fileprivate func calculate(_ touches: Set<UITouch>, withEvent event: UIEvent?, shouldCancel:Bool = true)
    {
        if let touch = touches.first
        {
            var point = touch.location(in: self)
            if(isVertical){
                point = CGPoint(x: self.bounds.height-point.y, y: point.x)
            }
            let arc = GNArc(bounds, vertical: self.isVertical, fliped: isFlipped)
			
            let angle = abs( arc.calculateAngle(point)-CGFloat.pi )
            if(angle < CGFloat.pi*0.5){
                selectionAngle = -(arc.endAngle-CGFloat.pi)
            }else if(angle < arc.startAngle)
            {
                selectionAngle = -(arc.startAngle-CGFloat.pi)
            }else if(angle >= arc.endAngle)
            {
                selectionAngle = -(arc.endAngle-CGFloat.pi)
            }else{
                selectionAngle = arc.calculateAngle(point)
            }
            range.valuePercent = arc.calculatePercent(selectionAngle);
            body.centerBased = self.minimumValue < 0
			selectedBody.percent(arc.calculatePercent(selectionAngle))
			selectedLabels.percent(arc.calculatePercent(selectionAngle))
            value = range.value
        }
    }
    // MARK: Touches
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEditing = true;
        hasMoved = false;
        super.touchesBegan(touches, with: event)
    }
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        hasMoved = true;
        calculate(touches, withEvent: event,shouldCancel: false);
        setNeedsDisplay()
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEditing = false;
        hasMoved = false;
        setNeedsDisplay()
        super.touchesCancelled(touches, with: event)
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEditing = false;
        if(!hasMoved){
            hasMoved = false;
            calculate(touches, withEvent: event);
        }
        setNeedsDisplay()
        super.touchesEnded(touches, with: event)
    }
}

