//
//  CatogariesController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/12.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

class CatogariesController: UIViewController {

    class func Nib() -> CatogariesController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        return (sb.instantiateViewControllerWithIdentifier("CatogariesController") as? CatogariesController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
