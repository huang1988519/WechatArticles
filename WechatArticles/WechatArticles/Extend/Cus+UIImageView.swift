//
//  Cus+UIImageView.swift
//  WechatArticle
//
//  Created by hwh on 15/11/17.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView
//import Kingfisher

extension UIImageView {
    public func showHUD() -> UIView {
        return showHUD(UIColor.cus_RedColor())
    }
    public func showHUD(color:UIColor) ->UIView {
        hideHUD()
        
        let loading = createHud(color)
        self.addSubview(loading)
        return loading
    }
    
    public func hideHUD() {
        if let view = self.viewWithTag(loadingViewTag) {
            view.removeFromSuperview()
        }
    }
    internal func addSubViewToSelfView(view:UIView) {
        self.addSubview(view)
        if let view = self.viewWithTag(loadingViewTag) {
            self.bringSubviewToFront(view)
        }
    }
    
    //MARK: --
    internal func createHud(color:UIColor) -> UIView {
        let size   = CGSizeMake(80, 80)
        let center = self.center
        
        let loading = NVActivityIndicatorView(frame: CGRectMake(0, 0, size.width, size.height), type: .SemiCircleSpin, color: color, size: size)
        loading.tag = loadingViewTag
        loading.center = center
        loading.startAnimation()
        
        return loading
    }
    //MARK: - 下载
    func setUrlString(string:String) {
        let url = NSURL(string: string)
        setUrl(url!)
    }
    func setUrl(url:NSURL) {
        self.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil) {[unowned self] (image, error, cacheType, imageURL) -> () in
            //TO-DO: 图片下载完成
        }
    }
}
