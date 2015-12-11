//
//  ArticleController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/13.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring
//import JLToast
//import AVOSCloud



class ArticleController: UIViewController ,UIWebViewDelegate,UIScrollViewDelegate{
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: SpringButton!
    
    var inputDic : [String:AnyObject]?
    
    class func Nib() -> ArticleController{
        let sb = UIStoryboard(name: "Main", bundle: nil)
        return (sb.instantiateViewControllerWithIdentifier("ArticleController") as? ArticleController)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if inputDic == nil {
            log.error("传入的字典不能为空")
            return
        }

        if let title = inputDic!["title"] as? String {
            titleLabel.text = title
        }
        if let _url = inputDic!["url"] as? String {
            let url = NSURL(string: _url)

            webView.loadRequest(NSURLRequest(URL: url!))
            webView.scrollView.delegate = self
        }
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func showMore(sender: AnyObject) {
        let shareView = ShareViewController.Nib()
        shareView.changeFontBlock = {[unowned self](size) -> Void in
            self.changeFontSize(size!)
            }
        shareView.openInSafariBlock = {[unowned self](url) -> Void in
            self.openInSafari(nil)
        }
        shareView.copyClickBlock = {[unowned self](url) -> Void in
            self.copyUrl()
        }
        shareView.wechatClickBlock = {[unowned self](url) -> Void in
            self.shareToWechat()
        }
        /*
        shareView.favoriteClickBlock = {[unowned self](url) -> Void in
            self.favorite()
        }
*/
        shareView.show(self)
    }
    func changeFontSize(size:Double) {
        let js = "var x = document.getElementsByClassName(\"rich_media_content\");\nvar i;\nfor (i = 0; i < x.length; i++) {\n    x[i].style.fontSize = \'\(size)px\'\n}"
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    func openInSafari(urlString: String?) {
        if let _url = inputDic!["url"] as? String {
            let url = NSURL(string: _url)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    func copyUrl() {
        
        if let _url = inputDic!["url"] as? String {
            let parseBoard = UIPasteboard.generalPasteboard()
            parseBoard.string = _url
            JLToast.makeText("复制成功").show()
        }
    }
    func shareToWechat() {
        let message = MonkeyKing.Message
    }
    /*
    func favorite() {
        if GetUserInfo() == nil {
            JLToast.makeText("请先登录才能使用收藏功能").show()
            return
        }
        let user = AVUser.currentUser()
        
        if let article = inputDic {
            let article_id = article["id"] as? String
            if isFavoried(article_id) {
                JLToast.makeText("您已经收藏过了").show()
                return
            }

            
            let articleObject = AVObject(className: FavoriteClassNameKey)
            for (key, value) in article {
                articleObject[key] = value
            }
            articleObject[ArticleIdKey] = article["id"]
            articleObject[UserIdKey] = user.objectId
            
            let isSuc = articleObject.save()
            if isSuc {
                JLToast.makeText("收藏成功").show()
            }else {
                JLToast.makeText("收藏失败").show()
            }
        }
    }
    func isFavoried(article_id: String?) -> Bool {
        if article_id == nil {
            return false
        }
        let user =  AVUser.currentUser()
        
        let query = AVQuery(className: FavoriteClassNameKey)
        query.whereKey(ArticleIdKey, equalTo: article_id)
        query.whereKey(UserIdKey, equalTo: user.objectId)
        
        let favorites = query.findObjects()
        if (favorites != nil) && favorites.isEmpty == false {
            return true
        }
        return false
    }
*/
    //MARK: -- UIWebViewDelegate
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.hideHUD()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.hideHUD()
        changeReadState()
        self.dismissButton.alpha = 1
    }
    func webViewDidStartLoad(webView: UIWebView) {
        self.showHUD()
    }
    
    //MARK: --
    func changeReadState() {
        if let id = inputDic!["id"] as? String{
            hadReadList.append(id)
//            DB.inertReadRecord(id) //暂时不使用数据库了
        }
    }
    //MARK: -- ScrollView Delegate 
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.dismissButton.alpha = 1
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.dismissButton.alpha = 0.1
    }
}
