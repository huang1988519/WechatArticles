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
    
    public func showHUD() {
        HUD.show(.Progress)
    }
    
    public func hideHUD() {
        HUD.hide()
    }
}
