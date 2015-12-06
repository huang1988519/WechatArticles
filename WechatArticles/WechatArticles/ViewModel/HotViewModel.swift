//
//  HotViewModel.swift
//  WechatArticle
//
//  Created by hwh on 15/11/11.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

typealias CompleteHandle = (result: AnyObject?, error:String?) -> Void

class HotViewModel: NSObject {
    let request = HotRequest()
    
    
    override init() {
        super.init()
    }
    deinit {
        log.debug("%p", args: request)
        log.warning("消除")
    }
    
    func requestList(start :()->(),comleteBlock:CompleteHandle?) {
        request.request(
            { (data) -> Void in
                log.verbose(data)
                if let _comBlock = comleteBlock {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            _comBlock(result: data, error: nil)
                    })
                }
            
            }) { (msg) -> Void in
                
                log.error(msg)
                alertWithMsg(msg)
                if let _comBlock = comleteBlock {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        _comBlock(result: nil, error: msg)
                    })
                }
        }
    }
}
