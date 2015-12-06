//
//  ArticleListRequest.swift
//  WechatArticle
//
//  Created by hwh on 15/11/13.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

class ArticleListRequest: Request {
    var page = 1
    var keywords = ""
    var typeId = 0
    
    override func configRequest() {
        urlPath = Request_Path.goodArticle
    }
    
    override func handleResult() -> AnyObject? {
        
        if let dic = resultObject {
            log.debug(resultObject)
            if let list = dic["pagebean"] {
                resultObject = list
            }
        }
        return resultObject
    }
}
