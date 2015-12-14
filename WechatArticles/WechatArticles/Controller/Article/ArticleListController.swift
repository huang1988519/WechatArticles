//
//  ArticleListController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/13.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring
//import MJRefresh

@objc protocol ArticleDelegate {
    func dismissArticle()
}
enum InputDictionayKeys:String {
    case ID   = "id"
    case Name = "name"
}
struct Result {
    var pageCount   = 0
    var totalNumber = 0
    var list:[[String:AnyObject]]?
}
class ArticleListController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UIViewControllerTransitioningDelegate{
    //MARK: - 实例
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: SpringButton!
    @IBOutlet weak var pageLabel: SpringLabel!
    
    weak var articleDelegate: ArticleDelegate?
    let request = ArticleListRequest()
    
    var inputDic:[String: AnyObject]?
    var resultModel = Result()
    var isLoadingMore = false //是否正在加载更多
    var isRequesting  = false //正在请求网络

    var lastIndexPath : NSIndexPath?
    var currentPage = 1 {
        didSet {
            pageLabel.text = "\(currentPage)"
            pageLabel.animation = "slideUp"
            pageLabel.damping   = 0.9
            pageLabel.duration  = 1.5
            pageLabel.animate()
        }
    }
    lazy var presentAnimation:TransitionZoom = {
        return TransitionZoom()
    }()
    

    //MARK: - 方法
    class func Nib() -> ArticleListController {
        let vc = MainSB().instantiateViewControllerWithIdentifier("ArticleListController")
        return (vc as? ArticleListController)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = inputDic!["name"] as? String {
            titleLabel.text = title
        }else{
            titleLabel.text = "你愁啥"
        }

        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.header = MJRefreshNormalHeader.init { [unowned self]() -> Void in
            self.startReqeust()
        }
        tableView.footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { [unowned self]() -> Void in
            self.loadMore()
        })
        
        if let _id = inputDic![InputDictionayKeys.ID.rawValue] as? String {
            request.typeId = Int(_id)!
        }
        
        tableView.header.beginRefreshing()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if hadReadList.isEmpty == false && lastIndexPath != nil {
            tableView.reloadRowsAtIndexPaths([lastIndexPath!], withRowAnimation: .Fade)
        }
    }
    func startReqeust() {
        isLoadingMore = false
        currentPage = 1
        requestList(currentPage)
    }
    func loadMore() {
        isLoadingMore = true
        currentPage = ++request.page
        requestList(currentPage)
    }
    func requestList(page:Int) {
        if isRequesting {
            log.warning("正在请求网络，请客官等等好不啦")
            return
        }
        self.showHUD()
        
        request.page = page
        request.request({ [unowned self](data) -> Void in
            log.debug(data)
            
            self.endRefreshAnimation()
            self.unpackageResult(data)
            
            }) { [unowned self](msg) -> Void in
                self.endRefreshAnimation()
                alertWithMsg(msg)
        }
        isRequesting = true
    }
    func endRefreshAnimation() {
        hideHUD()
        isRequesting = false
        tableView.header.endRefreshing()
        tableView.footer.endRefreshing()
    }
    func unpackageResult(result:AnyObject?) {
        if let dic = result as? [String: AnyObject] {
            let pages   = dic["allPages"]
            let numbers = dic["allNum"]
            
            let lists   = dic["contentlist"]
            
            resultModel.pageCount   = (pages as? Int)!
            resultModel.totalNumber = (numbers as? Int)!
            
            var arr = [[String:AnyObject]]()
            if resultModel.list?.isEmpty == false && isLoadingMore == true{
                arr +=  resultModel.list!
            }
            if let list = lists as? [[String :AnyObject]] {
                arr += list
            }
            resultModel.list        = arr
            
            tableView.reloadData()
            dismissButton.alpha = 1
        }
    }
    //MARK: --
    @IBAction func goBack(sender: UIButton) {
        if let _delgate = articleDelegate {
            _delgate.dismissArticle()
        }
    }
    func isRead(articleId:String) -> Bool {
        return hadReadList.contains(articleId)
//        return  DB.hadRead(articleId)//暂时去掉数据库查询，目测有点卡,需要优化
    }
    //MARK: --
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = resultModel.list![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? ArticleListCell
        let imageUrl  = NSURL(string: (node["contentImg"] as? String)!)
        let avatarUrl = NSURL(string: (node["userLogo"] as? String)!)
        cell?.contentLabel.text = node["title"] as? String
        cell?.coverImageView.setUrl(imageUrl!)
        if let _ =  avatarUrl {
//            cell?.avatar.setUrl(avatarUrl!)
        }
        cell?.ttitleLabel.text = node["userName"] as? String
        cell?.dateLabel.text = node["date"] as? String
        
        if isRead((node["id"] as? String)!) {
            cell?.contentLabel.textColor = UIColor(white: 0.5, alpha: 1)
        }else{
            cell?.contentLabel.textColor = UIColor(white: 0.2, alpha: 1)
        }
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultModel.list == nil || resultModel.list?.isEmpty == true {
            return 0
        }
        return (resultModel.list?.count)!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        let node = resultModel.list![indexPath.row]
        lastIndexPath = indexPath
        
        let detailVC = ArticleController.Nib()
        detailVC.inputDic = node
        detailVC.transitioningDelegate = self
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    //MARK: -- Animatin Transition
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForPresentedController(presented, presentingController: presenting, sourceController: source)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForDismissedController(dismissed)
    }
    //MARK: -- UIScrollView Delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.dismissButton.alpha = 1
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.dismissButton.alpha = 0.1
    }
}
