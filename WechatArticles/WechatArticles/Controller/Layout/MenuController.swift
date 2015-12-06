//
//  MenuController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/8.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
@objc protocol  MenuItemSelectDelegate {
     optional func menuDidSelectItem(title:String, index:NSIndexPath)
}

class MenuController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

    let menuItems = ["热门","反馈","设置"]
    var delegate: MenuItemSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView Delegate & Datasource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        //设置cell 字体
        var token: dispatch_once_t = 0
        dispatch_once(&token) { () -> Void in
            cell.textLabel?.font = UIFont.systemFontOfSize(14)
        }
        
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == menuItems.count-1 {
            
        }
    }
}
