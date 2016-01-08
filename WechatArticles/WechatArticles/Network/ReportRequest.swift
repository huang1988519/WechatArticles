//
//  ReportRequest.swift
//  WechatArticles
//
//  Created by hwh on 16/1/8.
//  Copyright © 2016年 hwh. All rights reserved.
//

import UIKit

class ReportRequest: Request {
    override func configRequest() {
        urlPath = Request_Path.goodArticles
    }
    override func handleResult() -> AnyObject? {
        super.handleResult()
        
        if let dic = resultObject {
            log.debug(resultObject)
            if let list = dic["typeList"] {
                resultObject = list
            }
        }
        return resultObject
    }
}
