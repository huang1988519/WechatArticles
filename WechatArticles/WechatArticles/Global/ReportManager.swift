//
//  ReportManager.swift
//  WechatArticles
//
//  Created by hwh on 3/2/16.
//  Copyright © 2016 hwh. All rights reserved.
//

import Foundation

final class ReportManager: NSObject {
    private static let _manager = ReportManager()
    private var reportList = [String]() //存储举报列表
    
    var sucessBlock: (Bool -> Void)?
    
    class func ShareInstance() -> ReportManager {
        return _manager
    }
    
    class func Synchronous() {
        let manager = ReportManager.ShareInstance()
        manager.getReportList()
    }
    class func ReportArticleId(articleId: String, sucessHandle: (Bool -> Void)?=nil) -> Bool {
        let manager = ReportManager.ShareInstance()
        if sucessHandle != nil {
            manager.sucessBlock = sucessHandle
        }
        manager.report(articleId)
        return true
    }
    class func ContainID(articleID : String ) -> Bool {
        let manager = ReportManager.ShareInstance()
        return manager.contain(articleID)
    }
}

extension ReportManager {
    func getReportList() {
        let session = configCerSession()
        
        let _url = NSURL(string: "http://104.224.139.177:8080/getReports")
        guard let url = _url  else {
            return
        }
//        NSURLRequest.allowsWeakReference()
        let task = session.dataTaskWithRequest(NSURLRequest(URL: url)) {[weak self] (data, res, err) -> Void in
            if err != nil {
                log.error("获取不到举报列表\(err)")
                return
            }
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                guard let reslut = object as? [String:AnyObject] , let list =  reslut["Data"] as? [String] else {
                    log.error("获取不到举报列表")
                    return
                }
                log.verbose("获取举报列表成功 \(list)")
                self!.reportList = list
            }catch {
                log.error(error)
            }

        }
        task.resume()
    }
    
    func report(reportId: String) {
        let manger = ReportManager.ShareInstance()
        let session = configCerSession()
        var sucess = true
        defer {
            if manger.sucessBlock != nil {
                manger.sucessBlock!(sucess)
            }
        }
        let _url = NSURL(string: "http://104.224.139.177:8080/uploadReport?report=\(reportId)")
        guard let url = _url  else {
            sucess = false
            return
        }
        
        let task = session.dataTaskWithRequest(NSURLRequest(URL: url)) { (data, res, err) -> Void in
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                guard let reslut = object as? [String:AnyObject] , let status =  reslut["Status"] as? Int else {
                    log.error("举报失败")
                    sucess = false
                    return
                }
                if status != 0 {
                    sucess = false
                }
                return
            }catch {
                log.error(error)
                sucess = false
                return
            }
            
        }
        task.resume()
    }
    
    func contain(artileID: String) -> Bool {
        if reportList.count <= 0 {
            return false
        }
        return reportList.contains(artileID)
    }
    
    func configCerSession() -> NSURLSession {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return  NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
}
extension ReportManager: NSURLSessionDelegate {
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        challenge.sender?.cancelAuthenticationChallenge(challenge)
    }

}
