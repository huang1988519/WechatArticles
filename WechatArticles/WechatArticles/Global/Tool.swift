//
//  Tool.swift
//  WechatArticle
//
//  Created by hwh on 15/11/12.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Kingfisher
import AVOSCloud
//import Timepiece

let FavoriteClassNameKey = "Favorite"
let ArticleIdKey = "articleId"
let UserIdKey    = "userId"


// 获取 主代理
func App() -> AppDelegate {
    return (UIApplication.sharedApplication().delegate as? AppDelegate)!
}
func MainSB() -> UIStoryboard {
    let sb = UIStoryboard(name: "Main", bundle: nil)
    return sb
}
var hadReadList = [String]() //已读列表，内存保存，退出销毁


// 全局提示框
func alertWithMsg(msg: String) {
    let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .Alert)
    let action = UIAlertAction(title: "确定", style: .Default) { (alert) -> Void in
        log.debug("[Alert]确定")
    }
    alert.addAction(action)
    alert.showViewController((App().window?.rootViewController)!, sender: nil)
}

//MARK: - 扩展 手写字体 
extension UIFont {
    class func handWriteFontOfSize(size: CGFloat) -> UIFont {
        let font = UIFont.systemFontOfSize(size)
        return font
    }
}

//MARK: -  登录相关
func GetUserInfo() -> AnyObject? {
    let user = AVUser.currentUser()
    return user
}

//MARK: -  是否是当天第一次启动app
func isFirstStartUpFromToday() -> Bool{
    let key = "isFirstStartup"
    let day = NSDate().day
    let lastday = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
    
    if "\(day)" == lastday {
        log.debug("不是第一天第一次启动")
        return false
    }
    NSUserDefaults.standardUserDefaults().setObject("\(day)", forKey: key)
    NSUserDefaults.standardUserDefaults().synchronize()
    log.debug("今天第一次启动，更新大背景图")
    
    return true
}
func lastArticleFontSize() -> Double {
    let key = "lastArticleFontSize"
    let fontsize = NSUserDefaults.standardUserDefaults().doubleForKey(key)
    if fontsize < 13 {
        return 13
    }
    return fontsize
}
func lastArticleFontSize(size: Double) {
    let key = "lastArticleFontSize"
    NSUserDefaults.standardUserDefaults().setDouble(size, forKey: key)
    NSUserDefaults.standardUserDefaults().synchronize()
}