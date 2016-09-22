//
//  WAHUDView.swift
//  WechatArticles
//
//  Created by huanwh on 16/9/22.
//  Copyright © 2016年 hwh. All rights reserved.
//

import UIKit

class WAHUDView: UIView {
    var views  = [UIView(),UIView(),UIView(),UIView()]
    var colors = [UIColor.init(colorLiteralRed: 138/255.0, green: 204/255.0, blue: 225/255.0, alpha: 0.8),
                  UIColor.init(colorLiteralRed: 185/255.0, green: 69/255.0, blue: 108/255.0, alpha: 0.8),
                  UIColor.init(colorLiteralRed: 69/255.0, green: 76/255.0, blue: 84/255.0, alpha: 0.8),
                  UIColor.init(colorLiteralRed: 252/255.0, green: 117/255.0, blue: 74/255.0, alpha: 0.8)
                  ]
    var animationTimer:NSTimer?
    var index = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = false
        
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    deinit {
        if  animationTimer!.valid{
            animationTimer!.invalidate()
        }
        animationTimer = nil
    }
    
    func initViews() {
        self.alpha = 0.8
        self.layer.masksToBounds = true
        self.layer.cornerRadius  = 10
        
        var i = 0;
        for view in views {
            self.addSubview(view)
            view.backgroundColor = colors[i]
            
            let center = centerForIndex(i)
            
            view.frame = CGRectMake(0, 0, 50, 50)
            view.center = center
            
            i = i+1;
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        startAnimation()
    }
    
    func centerForIndex(index: Int) -> CGPoint {
        let oneForFour = CGFloat(25)
        
        let x = index % 2;
        let y = index / 2;
        
        return CGPointMake(CGFloat(x) * oneForFour * 2 + oneForFour , CGFloat(y) * oneForFour * 2 + oneForFour )
    }
    
    //MARK: -  动画
    
    func startAnimation() {
        if  animationTimer != nil &&  animationTimer!.valid{
            animationTimer!.invalidate()
        }
        animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector:#selector(WAHUDView.animation), userInfo: nil, repeats: true)
    }
    
    func endAnimation() {
        if  animationTimer != nil && animationTimer!.valid{
            animationTimer!.invalidate()
        }
    }
    @objc func animation() {
        var i = 0
        for view in views {
            let p = (i + index) % 4
            
            view.backgroundColor = colors[p]
            
            i = i+1;
        }
        
        index = index + 1
    }
}
