//
//  AppDelegate.swift
//  WechatArticles
//
//  Created by hwh on 15/12/6.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import AVOSCloud
import Fabric
import Crashlytics

var log = Loggerithm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        config(launchOptions)
        
        return true
    }
    
    //MARK: --
    func config(launchOption: [NSObject: AnyObject]?) {
        //配置log
        log.showFunctionName = true
        log.showDateTime     = false
        log.verboseColor = UIColor.darkGrayColor()
        //配置 崩溃 日志
        Fabric.with([Crashlytics.self])
        //配置 leanCloud
//        AVOSCloud.setApplicationId("qfrsSEumQvfkvyR7gMSXErKg", clientKey: "nTSTQrCGKDFm9zQoexAJHhGW")
        //配置缓存
        ImageCache.defaultCache.calculateDiskCacheSizeWithCompletionHandler { (size) -> () in
            log.debug("图片缓存 %d M", args: size/1024/1024)
        }
        //注册通知
        let types : UIUserNotificationType = [.Alert,.Sound,.Badge]
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
    }
    
}

