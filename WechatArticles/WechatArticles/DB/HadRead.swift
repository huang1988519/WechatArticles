//
//  HadRead.swift
//  WechatArticle
//
//  Created by hwh on 15/11/18.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

let DBManager = SQLiteDB.sharedInstance()
public enum DBTables : String {
    
    case HadReadList = "hadReadList"
    case Column = ""
}
class DB : NSObject{
    class func inertReadRecord(articleId:String) -> Bool{
        let stamp = NSDate.stampForCurrentDate()
        let sql = "insert into \(DBTables.HadReadList.rawValue) (articleId,createAt) values ('\(articleId)','\(stamp)')"
        log.debug("sql:  \(sql)")
        let result =  DBManager.execute(sql)
        
        if result == 0 {
            log.debug("sql执行成功")
            return true
        }
        log.error("执行sql出错")
        return false
    }
    class func hadRead(articleId:String) -> Bool {
        let sql = "select articleId from \(DBTables.HadReadList.rawValue) where articleId = '\(articleId)'"
        log.debug("sql : \(sql)")
        let result =  DBManager.query(sql)
        if result.isEmpty {
            return false
        }
        let one = result[0]
        if let _ = one["articleId"] {
            log.debug("已读")
            return true
        }
        return false
    }
    /**
     获取数据库路径
     
     - returns: 数据库路径
     */
    class func isCacheExistDBAndCreate() -> String{
        let fileManager = NSFileManager.defaultManager()
        
        let bundlePath = NSBundle.mainBundle().pathForResource("WechatArticle", ofType: "sqlite3")
        let ducumentPath = NSHomeDirectory() + "/Documents/WechatArticle.sqlite3"
        
        if fileManager.fileExistsAtPath(ducumentPath) {
            return ducumentPath
        }
        
        do {
            try fileManager.moveItemAtPath(bundlePath!, toPath: ducumentPath)
            return ducumentPath
        }catch {
            log.error(error)
            return ""
        }
    }
    

}
