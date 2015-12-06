//
//  LinesView.swift
//  app_ios_b
//
//  Created by hwh on 15/10/20.
//  Copyright © 2015年 阿姨帮. All rights reserved.
//

import UIKit

public enum LineType : Int{
    case Top
    case Bottom
    case Left
    case Right
}

@IBDesignable class LinesView: UIView {
    @IBInspectable var lineBorderWidth:CGFloat = 0.3 //边界 宽度
    @IBInspectable var speratorOffset:CGFloat  = 0.0 // 分割线 位移

    @IBInspectable var bordColor:UIColor = UIColor.whiteColor()
    
    @IBInspectable var hasTop:Bool    = false
    @IBInspectable var hasBottom:Bool = false
    @IBInspectable var hasLeft:Bool   = false
    @IBInspectable var hasRight:Bool  = false
    
    @IBInspectable var lineEdges:[LineType]! = []
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext();


        assert(lineEdges != nil, "必须传入边界值")
        
        if (lineEdges.contains(LineType.Top) == true || hasTop == true){
            CGContextMoveToPoint(context, 0, 0)
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), 0)
        }
        if (lineEdges.contains(LineType.Bottom) == true || hasBottom != false){
            CGContextMoveToPoint(context, 0, CGRectGetMaxY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        }
        if lineEdges.contains(LineType.Left) == true || hasLeft{
            CGContextMoveToPoint(context, 0, 0)
            CGContextAddLineToPoint(context, 0, CGRectGetMaxY(rect))
        }
        if lineEdges.contains(LineType.Right) == true || hasRight{
            CGContextMoveToPoint(context, CGRectGetMaxX(rect), 0)
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        }
        
        
        CGContextSetStrokeColorWithColor(context, bordColor.CGColor)
        CGContextSetLineWidth(context, lineBorderWidth)
        CGContextStrokePath(context)
        
        if speratorOffset>0 {
            CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)
            CGContextSetLineWidth(context, 0.3)
            CGContextMoveToPoint(context, speratorOffset, CGRectGetMaxY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
            CGContextStrokePath(context)
        }
    }

}
