//
//  ShareViewController.swift
//  WechatArticle
//
//  Created by hwh on 15/11/20.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring

class ShareViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{

    weak var parentVC : UIViewController?
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareViewBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var fontLabel: UILabel!
    @IBOutlet weak var step: UIStepper!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var upCollectionView: UICollectionView!
    @IBOutlet weak var downCollectionView: UICollectionView!
    
    var favoriteClickBlock :([String:AnyObject]? -> Void)?
    var copyClickBlock     :((String?) -> Void)?
    var openInSafariBlock  :((String?) -> Void)?
    var changeFontBlock    :((Double?) -> Void)?
    class func Nib() -> ShareViewController {
        let sb = MainSB().instantiateViewControllerWithIdentifier("ShareViewController")
        return (sb as? ShareViewController)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        insertBlurView(backView, style: .Light)
        backView.alpha = 0.5
        shareView.layer.borderWidth = 0.3
        shareView.layer.borderColor = UIColor.lightGrayColor().CGColor
        fontView.hidden = true
        step.value = lastArticleFontSize()
        
        UIDevice.currentDevice().identifierForVendor
    }
    deinit {
        log.debug("分享界面消除")
    }
    func show(controller: UIViewController) {
        let rootViewController = controller
        parentVC = controller
        
        rootViewController.addChildViewController(self)
        let rect = rootViewController.view.bounds

        self.view.frame = rect
        backView.alpha = 0
        rootViewController.view.addSubview(self.view)
        shareViewBottomConstant.constant = -260
        self.view.layoutIfNeeded()
        
        shareViewBottomConstant.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [.CurveEaseIn], animations: { () -> Void in
            self.backView.alpha = 0.8
            self.view.layoutIfNeeded()
            
            }) { (sucess) -> Void in
                
        }
    }
    func showFontView() {
        fontView.alpha = 0
        fontView.hidden = false
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.fontView.alpha = 1
        }
    }
    func dismissShareView() {
        shareViewBottomConstant.constant = -260
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (complete) -> Void in
        })
    }
    @IBAction func dismiss(sender: AnyObject?) {
        if let _ = parentVC {

            shareViewBottomConstant.constant = -260
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.backView.alpha = 0
                self.fontView.alpha = 0
            }, completion: { (complete) -> Void in
                self.view.removeFromSuperview()
                
                if self.parentViewController != nil {
                    self.removeFromParentViewController()
                }
           })
            
        }
    }
    @IBAction func changeFontSize(sender: UIStepper) {
        let fontSize = sender.value
        fontLabel.text = "\(UInt(fontSize))"
        
        if let _font = changeFontBlock {
            _font(fontSize)
        }
    }
    //MARK: -- Collectionview datasource & delegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? ShareViewCell)!
        if collectionView == upCollectionView {
            cell.titleLabel.text = "收藏"
        }else{
            if indexPath.row == 0 {
                cell.titleLabel.text = "复制连接"
            }
            if indexPath.row == 1 {
                cell.imageView.image = UIImage(named: "safari")
                cell.titleLabel.text = "open in safari"
            }
            if indexPath.row == 2 {
                cell.imageView.image = UIImage(named: "fontsize")
                cell.titleLabel.text = "字号"
            }
            
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView ==  upCollectionView {
            return 1
        }else{
            return 3
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if collectionView ==  upCollectionView {
            if let _fav = favoriteClickBlock {
                dismiss(nil)
                _fav(nil)
            }
        }else{
            if indexPath.row == 0 {
                dismiss(nil)
                if let _cp = copyClickBlock {
                    _cp(nil)
                }
            }else if indexPath.row == 1 {
                dismiss(nil)
                if let _open = openInSafariBlock {
                    _open(nil)
                }
            }else if indexPath.row == 2 {
                dismissShareView()
                showFontView()
            }
        }
    }
}
