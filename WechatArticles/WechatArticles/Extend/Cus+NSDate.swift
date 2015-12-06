
//
//  Cus+NSDate.swift
//  WechatArticle
//
//  Created by hwh on 15/11/18.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

extension NSDate {
    //获取时间戳
    class func stampForCurrentDate() -> NSTimeInterval {
        return  NSDate().timeIntervalSince1970
    }
}
