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
        if self.view.viewWithTag(loadingViewTag) != nil {
            self.view.viewWithTag(loadingViewTag)?.removeFromSuperview()
        }
        
        let view = WAHUDView()
        view.tag = loadingViewTag
        
        self.view.addSubview(view)
        
        view.snp_makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.size.equalTo(CGSizeMake(100, 100))
        }

    }
    
    public func hideHUD() {
        if self.view.viewWithTag(loadingViewTag) != nil {
            self.view.viewWithTag(loadingViewTag)?.removeFromSuperview()
        }
    }
}
