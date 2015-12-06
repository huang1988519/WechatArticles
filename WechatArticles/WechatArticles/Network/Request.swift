//
//  Request.swift
//  WechatArticle
//
//  Created by hwh on 15/11/10.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

enum REQUEST_TYPE: Int {
    case Get
    case Post
}
//enum ResponseStatus: Int {
//    case Wait       //未启动
//    case Start      //请求开始
//    case Requesting //请求中。。。
//    case Failed     //请求失败
//    case Sucess     //请求成功
//    
//    case Suspend    //请求暂停
//    case Resume     //请求重新开始
//}
public struct Request_Path {
    static let detail_list  = "weixin_num_list"     //详情列表（关键字搜索）
    static let type_list    = "winxin_num_type"     //类型列表
    static let goodArticle  = "weixin_article_list" //精选
    static let goodArticles = "weixin_article_type" //文章_微信精选文章类别
}

typealias SucessHandle = (data:AnyObject?) -> Void
typealias FaildHandle  = (msg: String!)    -> Void

public class Request: NSObject {
    private var BASEURL = "http://apis.baidu.com/showapi_open_bus/weixin/"
    var methed  = REQUEST_TYPE.Get
    public var urlPath = Request_Path.detail_list

    private var respondeData  : NSData?
    internal var resultObject:AnyObject?
    
    let session = NSURLSession.sharedSession()
    var task: NSURLSessionTask?
    
//    var state: Variable<ResponseStatus> = Variable(.Wait)
    
    var _successBlock:SucessHandle?
    var _faildBlock  :FaildHandle?
    
    deinit {
        log.warning("消除")
    }
    //配置 生成 request
    func configRequest() {
        log.verbose("配置 request")
    }
    func request(sucessBlock: SucessHandle , faildBlock:FaildHandle) {
        _successBlock = sucessBlock
        _faildBlock   = faildBlock
        
        start()
    }
    private func start() {
        configRequest()
        
        let url = generateUrl()
        let request = NSMutableURLRequest(URL: NSURL(string: url!)!)
        request.addValue("9fe31d289ac7abf25244f79300c41ca4", forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30
        #if DEBUG
        request.timeoutInterval = 10
        #endif

        task = session.dataTaskWithRequest(request) { [weak self](data, response, error) -> Void in
            
            let strongSelf = self
            
            if let _err = error {
                log.error(_err)
//                strongSelf?.state = Variable(.Failed)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self!._faildBlock!(msg: "网络失败\n\(_err.description)")
                    })
                return
            }else{
                let (result,errorMsg) = (strongSelf?.dealWithResult(data!))!
                
                if errorMsg != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?._faildBlock!(msg: errorMsg)
                    })
                }else{
                    self!.resultObject = result
                    
                    strongSelf?.handleResult()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?._successBlock!(data: self?.resultObject)
                    })
                }
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        task?.resume()

//        state = Variable(.Start)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    func resume() {
        if let _task = task {
            _task.resume()
        }
    }
    func suspend() {
        if let _task = task {
            _task.suspend()
        }
    }
    func cancel() {
        if let _task = task {
            _task.cancel()
        }
        task = nil
    }
    func dealWithResult(data: NSData) -> (reuslt:AnyObject?, errorMsg: String?) {
        
        respondeData = data
        
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dic = (object as? [String: AnyObject]) {
                if let code = (dic["showapi_res_code"] as? NSNumber) {
                    if code == 0{
                        let result = dic["showapi_res_body"] as? [String:AnyObject]
                        return (result,nil)
                    }else{
                        let errorMsg = dic["showapi_res_error"] as? String
                        return (nil, errorMsg)
                    }
                }else {
                    return (nil,"json 结构不对，请开发者检查返回格式是否正确")
                }
            }else {
                return (nil,"返回结果不是字典格式")
            }
            
        }catch {
            log.error(error)
            return (nil,"json 解析错误")
        }
    }
    //重写此方法，处理返回 结果
    func handleResult() -> AnyObject? {
        if let dic = resultObject as? [String:AnyObject] {
            if let list = dic["typeList"] {
                resultObject = list
            }
        }
        return resultObject
    }
    //MARK: -
    private func generateUrl() -> String?{
        
        let paras = parasForSelf()
        var paramsString = ""
        for (key,value) in paras {
            paramsString += "\(key)=\(value)"
            paramsString += "&"
        }
        return BASEURL + urlPath  + "?" + paramsString
    }
    private func parasForSelf() -> [String:AnyObject] {

        var count:UInt32 = 0
        let properties = class_copyPropertyList(self.classForCoder, &count)
        
        var paras = [String: AnyObject]()
        
        for var i = 0 ; i < Int(count); i++ {
            let property = properties[i]
            let key = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)!
            
            if let value = valueForKey("\(key)") {
                log.verbose("\(key) = \(value)")
                paras[String(key)] = value
            }

        }
        return paras
    }
}
