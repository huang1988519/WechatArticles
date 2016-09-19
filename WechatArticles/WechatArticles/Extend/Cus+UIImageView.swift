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
    //MARK: - 下载
    func setUrlString(string:String) {
        let url = NSURL(string: string)
        setUrl(url!)
    }
    func setUrl(url:NSURL) {
        self.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: nil) { (image, error, cacheType, imageURL) -> () in
            //TO-DO: 图片下载完成
        }
    }
}
