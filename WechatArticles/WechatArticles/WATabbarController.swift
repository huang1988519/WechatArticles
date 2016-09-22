//
//  WATabbarController.swift
//  WechatArticles
//
//  Created by huanwh on 16/9/22.
//  Copyright © 2016年 hwh. All rights reserved.
//

import UIKit

class WATabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName: UIColor.orangeColor()], forState:.Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)], forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
