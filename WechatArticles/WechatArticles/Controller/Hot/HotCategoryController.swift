//
//  HotCategoryController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/13.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Kingfisher

@objc class HotCategoryController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UIViewControllerTransitioningDelegate,ArticleDelegate {
    let hotModel = HotViewModel()

    @IBOutlet weak var coverImageView: SpringImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var resultArray :[[String:AnyObject]]?
    lazy var presentAnimation: PresentTransition = {
        return PresentTransition()
    }()
    
    
    //MARK: -
    class func Nib() -> HotCategoryController {
        return (MainSB().instantiateViewControllerWithIdentifier("HotCategoryController") as? HotCategoryController)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
        requestNewestImageFromBing()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: -  网络
    func refresh() {
        self.showHUD()

        hotModel.requestList(
            {[unowned self] () -> () in
                self.hideHUD()
                self.collectionView.showLoading()
            }) { [unowned self](result, error) -> Void in
                self.hideHUD()
                self.collectionView.hideLoading()
                
                if let list = result as? [[String:AnyObject]] {
                    self.resultArray = list
                    self.collectionView.reloadData()
                }
                if error != nil {
                    JLToast.makeText("摇一摇 刷新首页").show()
                }
        }
    }
    func requestNewestImageFromBing() {
        let cacheManager = ImageCache(name: "index")
        
        let address = "http://tu.ihuan.me/tu/api/bing/go/"
        let url     = NSURL(string: address)
        if isFirstStartUpFromToday() == true {
            cacheManager.removeImageForKey("index")
        }else{
        }
        let image = cacheManager.retrieveImageInDiskCacheForKey("index")
        if let _ = image {
            coverImageView.animation = "fadeIn"
            coverImageView.animate()
            coverImageView.image = image
        }else {
            ImageDownloader(name: "index").downloadImageWithURL(
                url!,
                progressBlock: nil)
                {[unowned self] (image, error, imageURL, originalData) -> () in
                    self.coverImageView.animation = "fadeIn"
                    self.coverImageView.animate()
                    
                    UIView.animateWithDuration(0.5, animations: {
                        self.coverImageView.image = image;
                    })
                    
                    cacheManager.storeImage(image!, forKey: "index")
            }
        }
        
        coverImageView.kf_setImageWithURL(url!, placeholderImage: nil, optionsInfo: [.Options(.ForceRefresh)], completionHandler: {[unowned self] (image, error, cacheType, imageURL) -> () in
            self.coverImageView.startAnimating()
            self.coverImageView.image = image
            })
    }
    var delayValue:CGFloat = 0.15
    
    //MARK: -- CollectionView Datasource & Delegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let node = resultArray![indexPath.row]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        //标题
        let label = cell.contentView.viewWithTag(100) as? SpringLabel
        label?.text =  node["name"] as? String
        label?.delay =  CGFloat(delayValue  * CGFloat(rand()%10))
        label?.animate()
        //单字标题
        let oneLabel = cell.contentView.viewWithTag(102) as? UILabel
        if label?.text?.isEmpty == false {
            let index = label?.text!.startIndex.advancedBy(1)
            oneLabel?.text = label?.text?.substringToIndex(index!)
        }
        //icon
        let headerView = cell.contentView.viewWithTag(101) as? SpringView
        headerView?.delay = CGFloat(delayValue * CGFloat(rand()%10))
        headerView?.animate()
        let RRandom = CGFloat(rand()%255)/255.0
        let GRandom = CGFloat(rand()%255)/255.0
        let BRandom = CGFloat(rand()%255)/255.0

        headerView?.backgroundColor = UIColor(red: RRandom, green: GRandom, blue: BRandom, alpha: 1)
        delay(0.3) {[unowned self] () -> () in
            self.delayValue = 0.08
        }
        
        return cell
    }
    @objc func resetDelay() {
        delayValue = 0.08
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if resultArray == nil || resultArray?.isEmpty == true {
            return 0
        }
        return resultArray!.count
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let node = resultArray![indexPath.row]
        log.debug(node)
        
        let articleVC = ArticleListController.Nib()
        articleVC.articleDelegate = self
        articleVC.transitioningDelegate = self
        articleVC.inputDic  = node
        
        navigationController?.pushViewController(articleVC, animated: true);
        /*
        self.parentViewController!.presentViewController(articleVC, animated: true) { () -> Void in
        }
 */

    }
    
    //MARK: -- Animatin Transition
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForPresentedController(presented, presentingController: presenting, sourceController: source)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation.animationControllerForDismissedController(dismissed)
    }
    //MARK: --
    func dismissArticle() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
extension HotCategoryController {
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            JLToast.makeText("刷新首页").show()
            refresh()
        }
    }
}
