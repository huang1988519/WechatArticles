//
//  ViewController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/8.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
import PushKit
//import SnapKit

class ViewController:
    UIViewController,MenuItemSelectDelegate{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var hotController: HotCategoryController!
    var settingController : SettingController!
    var currentController   : UIViewController?
    
    static var token :dispatch_once_t = 0
    let model =  HotViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hotController = HotCategoryController.Nib()
        settingController = SettingController.Nib()
        self.addChildViewController(hotController)
        self.addChildViewController(settingController)
        
        showHotController(hotButton)
        
        setUpViews()
    }
    // 切换到 热点视图
    @IBAction func showHotController(sender:UIButton) {
        hotButton.selected = true
        settingButton.selected = false
        settingController.view.removeFromSuperview()
        
        containerView.addSubview(hotController.view)
        hotController.view.frame = containerView.bounds
        
        currentController = hotController
    }
    // 切换到 设置视图
    @IBAction func showCategoryController(sender:UIButton) {
        hotButton.selected = false
        settingButton.selected = true
        hotController.view.removeFromSuperview()
        
        containerView.addSubview(settingController.view)
        settingController.view.frame = containerView.bounds
        currentController = settingController
        
        settingController.didMoveToParentViewController(self)
    }
    /**
     创建视图
     */
    func setUpViews() {
        print(model, terminator: "")
    }
    /**
     打开左侧菜单
     
     - parameter sender: 按钮
     */
    @IBAction func click(sender: AnyObject) {
        self.slideMenuController()?.openLeft()
    }
}

