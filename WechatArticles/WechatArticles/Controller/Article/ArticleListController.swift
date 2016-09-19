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
    var list:[[String:AnyObject]] = [[String:AnyObject]]()
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
    
    
    let cacheManager = try! Cache<NSMutableDictionary>(name: "ListCache")
    
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
            
            let storeDic = cacheManager.objectForKey(_id)
            if storeDic != nil{
                readCache(storeDic!)
            }else {
                tableView.header.beginRefreshing()
            }
        }
        
    }
    deinit {
        log.debug("[释放]ArticleListController  ，并缓存列表")
        storeCache()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if hadReadList.isEmpty == false && lastIndexPath != nil {
            tableView.reloadRowsAtIndexPaths([lastIndexPath!], withRowAnimation: .Automatic)
        }
    }
    func startReqeust() {
        isLoadingMore = false
        currentPage = 1
        requestList(currentPage)
    }
    func loadMore() {
        isLoadingMore = true
        currentPage = currentPage + 1
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
            
            if  isLoadingMore == false{
                resultModel.list.removeAll()
            }
            guard let list = lists as? [[String :AnyObject]] else {
                return;
            }
            resultModel.list += list

            tableView.reloadData()
        }
    }
    //MARK: -- 缓存相关
    func readCache(storeDic:NSDictionary?) {
        guard let _ = storeDic else {
            log.debug("本地不存在缓存，刷新")
            return
        }
        if let _page = storeDic!["page"] as? Int {
            currentPage = _page
        }
        if let _offset = storeDic!["offset"] as? CGFloat {
            dispatch_async_safely_main_queue({ () -> () in
                self.tableView.contentOffset = CGPointMake(0, _offset)
            })
        }
        guard let data = storeDic!["data"] as? NSData else {
            return
        }
        do {
            let list = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            resultModel.list = (list as? [[String:AnyObject]])!
            if resultModel.list.isEmpty == false {
                log.debug("读取cache ，并刷新")
                tableView.reloadData()
            }
        }catch {
            log.debug(error)
        }
    }
    func storeCache() {
        do {
            let storeData = try NSJSONSerialization.dataWithJSONObject(resultModel.list, options: .PrettyPrinted)
            let storeDic = NSMutableDictionary()
            storeDic["data"] = storeData
            storeDic["page"] = currentPage
            storeDic["offset"] = tableView.contentOffset.y
            
            if let _id = inputDic![InputDictionayKeys.ID.rawValue] as? String {
                cacheManager.setObject(storeDic, forKey: _id) { () -> () in
                    log.debug("缓存完成")
                }
            }
        }catch {
            log.debug(error)
        }

    }
    //MARK: --
    @IBAction func goBack(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)

        if let _delgate = articleDelegate {
            _delgate.dismissArticle()
        }else {
        }
    }
    func isRead(articleId:String) -> Bool {
        return hadReadList.contains(articleId)
//        return  DB.hadRead(articleId)//暂时去掉数据库查询，目测有点卡,需要优化
    }
    //MARK: --
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let node = resultModel.list[indexPath.row]
        
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
            cell?.contentLabel.textColor = UIColor(white: 0.8, alpha: 1)
        }else{
            cell?.contentLabel.textColor = UIColor(white: 1, alpha: 1)
        }
        if let id = node["id"] {
            cell?.reported = ReportManager.ContainID("\(id)")
        }
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultModel.list.isEmpty == true {
            return 0
        }
        return (resultModel.list.count)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? ArticleListCell
        if cell?.reported ==  true {
            JLToast.makeText("内容被举报，暂时无法查看").show()
            return
        }
        let node = resultModel.list[indexPath.row]
        lastIndexPath = indexPath
        
        let detailVC = ArticleController.Nib()
        detailVC.inputDic = node
        detailVC.transitioningDelegate = self
        
        navigationController?.pushViewController(detailVC, animated: true)
//        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let size = UIScreen.mainScreen().bounds.size
        return 180 * (size.width / 320 );
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
