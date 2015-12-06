//
//  AboutController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/22.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

class AboutController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var isComplete = false
    
    class func Nib() -> AboutController {
        let vc = MainSB().instantiateViewControllerWithIdentifier("AboutController")
        return (vc as? AboutController)!
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://huang1988519.github.io/2015/11/22/%E5%85%B3%E4%BA%8E%E5%BE%AE%E9%98%85%E8%AF%BB/")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    //MARK: -- UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        isComplete = true
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if ((request.URL?.absoluteString.containsString("huang1988519.github.io")) == true) && isComplete == false {
            return true
        }
        return false
    }
}
