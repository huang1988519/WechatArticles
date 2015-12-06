//
//  RoundButton.swift
//  WechatArticle
//
//  Created by hwh on 15/11/19.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    @IBInspectable var boardColor  = UIColor.whiteColor()
    @IBInspectable var boardWidth:CGFloat  = 0.3
    @IBInspectable var cornerRadio:CGFloat = 0
    @IBInspectable var haveSeperate = false
    
    override func drawRect(rect: CGRect) {
        self.clipsToBounds = true
        self.layer.borderColor  = boardColor.CGColor
        self.layer.borderWidth  = boardWidth
        self.layer.cornerRadius = cornerRadio
    }

}
