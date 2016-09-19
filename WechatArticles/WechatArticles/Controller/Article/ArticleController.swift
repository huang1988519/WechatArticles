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
    var shareImage: UIImage? //分享 图片 ，异步加载
    
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
        fetchShareImage()
    }
    @IBAction func dismiss(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func more() {
        let alert = UIAlertController(title: "请选择操作内容", message: nil, preferredStyle: .ActionSheet)
        let reportAction = UIAlertAction(title: "举报", style: .Destructive) { [unowned self](action) -> Void in
            self.report()
        }
        let shareAction = UIAlertAction(title: "分享", style: .Default) { [unowned self](action) -> Void in
            self.shareSystem()
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in
            
        }
        alert.addAction(reportAction)
        alert.addAction(shareAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true ,completion:nil)
    }
    func report() {
        guard let id = inputDic!["id"] as? String else {
            alertWithMsg("取不到需要举报文章ID")
            return
        }
        
        ReportManager.ReportArticleId("\(id)") { (sucess) -> Void in
            if sucess == true {
                dispatch_async_safely_main_queue({ () -> () in
                    JLToast.makeText("举报成功").show()
                })
            }else {
                dispatch_async_safely_main_queue({ () -> () in
                    alertWithMsg("举报异常")
                })
            }
        }

//        let request = SimpleNetworking.sharedInstance
//        request.request(NSURL(string: "http://104.224.139.177/ayb/wechatArticle.php?")!, method: .GET, parameters: ["report":id]) { (data, response, error) -> Void in
//            log.debug(data)
//            guard let message = data!["message"] as? String  else {
//                dispatch_async_safely_main_queue({ () -> () in
//                    alertWithMsg("举报异常")
//                })
//                return
//            }
//            dispatch_async_safely_main_queue({ () -> () in
//                JLToast.makeText(message).show()
//            })
//        }
    }
     func shareSystem() {
        MonkeyKing.registerAccount(.WeChat(appID: WechatShare.AppID, appKey: WechatShare.AppSecret))
        let urlString     = inputDic!["url"] as! String
        let title         = "爱上『Hi阅读』"
        let description   = inputDic!["title"] as! String
        var image         = UIImage(named: "icon180")!
        if let _ = shareImage {
            image = shareImage!
        }
        let shareURL = NSURL(string: urlString)!
        
        
        let info = MonkeyKing.Info(
            title: title,
            description: description,
            thumbnail: image,
            media: .URL(shareURL)
        )
        
        let sessionMessage = MonkeyKing.Message.WeChat(.Session(info: info))
        
        let weChatSessionActivity = AnyActivity(
            type: WechatShare.sessionType,
            title: NSLocalizedString("微信", comment: ""),
            image: UIImage(named: "weixin")!,
            message: sessionMessage,
            finish: { success in
                print("Session success: \(success)")
            }
        )
        
        let timelineMessage = MonkeyKing.Message.WeChat(.Timeline(info: info))
        
        let weChatTimelineActivity = AnyActivity(
            type: WechatShare.timeLineType,
            title: NSLocalizedString("朋友圈", comment: ""),
            image: UIImage(named: "timeline")!,
            message: timelineMessage,
            finish: { success in
                print("Timeline success: \(success)")
            }
        )
        
        let activityViewController = UIActivityViewController(activityItems: [description,shareURL,image], applicationActivities: [weChatSessionActivity, weChatTimelineActivity])
        
        presentViewController(activityViewController, animated: true, completion: nil)

    }
    func fetchShareImage() {
        let imageUrl = inputDic!["contentImg"] as! String
        ImageDownloader(name: "self").downloadImageWithURL(
            NSURL(string: imageUrl)!,
            progressBlock: nil) {[unowned self] (image, error, imageURL, originalData) -> () in
                if let _ = image {
                    self.shareImage = image
                }
        }
    }
    //MARK: -- UIWebViewDelegate
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.hideHUD()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.hideHUD()
        changeReadState()
    }
    func webViewDidStartLoad(webView: UIWebView) {
        self.showHUD()
    }
    
    //MARK: --
    func changeReadState() {
        if let id = inputDic!["id"] as? String{
            hadReadList.append(id)
        }
    }
}
