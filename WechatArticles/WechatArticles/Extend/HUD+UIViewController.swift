//
//  UIViewControllerExtend.swift
//  WechatArticle
//
//  Created by hwh on 15/11/16.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView

let loadingViewTag = 1000

extension UIViewController {
    
    public func showHUD() -> UIView {
        return showHUD(UIColor.cus_RedColor())
    }
    public func showHUD(color:UIColor) ->UIView {
        hideHUD()
        
        let loading = createHud(color)
        self.view.addSubview(loading)
        return loading
    }
    
    public func hideHUD() {
        if let view = self.view.viewWithTag(loadingViewTag) as? NVActivityIndicatorView{
            view.stopAnimation()
            view.removeFromSuperview()
        }
    }
    internal func addSubViewToSelfView(view:UIView) {
        self.view.addSubview(view)
        if let view = self.view.viewWithTag(loadingViewTag) {
            self.view.bringSubviewToFront(view)
        }
    }
    
    //MARK: --
    internal func createHud(color:UIColor) -> UIView {
        let size   = CGSizeMake(80, 80)
        let center = self.view.center
        
        let loading = NVActivityIndicatorView(frame: CGRectMake(0, 0, size.width, size.height), type: .BallClipRotatePulse, color: color, size: size)
        loading.userInteractionEnabled = false
        loading.tag = loadingViewTag
        loading.center = center
        loading.startAnimation()
        return loading
    }
}
