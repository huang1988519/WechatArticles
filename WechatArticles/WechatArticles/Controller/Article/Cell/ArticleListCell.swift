//
//  ArticleListCell.swift
//  WechatArticle
//
//  Created by hwh on 15/11/17.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring

class ArticleListCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var coverImageView: AsyncImageView!
    
    var reported:Bool = false {//是否被举报，默认是no
        didSet {
            if reported == true {
                self.contentLabel.text = "内容被举报，暂无法查看"
                self.contentLabel.textColor = UIColor.orangeColor()
                coverImageView.setUrlString("www.baidu.com")
//                coverImageView.setURL(NSURL(string: "www.baidu.com"), placeholderImage: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.cornerRadius  = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(item: AnyObject?) {
        guard let node = item as? [String: AnyObject] else {
            return;
        }
        
        let imageUrl  = NSURL(string: (node["contentImg"] as? String)!)
        let avatarUrl = NSURL(string: (node["userLogo"] as? String)!)
        self.contentLabel.text = node["title"] as? String
        self.coverImageView.setUrl(imageUrl!)
        if let _ =  avatarUrl {
            //            cell?.avatar.setUrl(avatarUrl!)
        }
        
        if let title = node["userName"] as? String {
            self.titleButton.setTitle(title, forState: .Normal);
        }
        self.dateLabel.text = node["date"] as? String
        
        if let id = node["id"] {
            self.reported = ReportManager.ContainID("\(id)")
        }
        
        if let readNum = node["read_num"] as? Int {
            self.detailLabel.text = "阅读 \(readNum)"
        }
        if let likeNum = node["like_num"] as? Int {
            var text = self.detailLabel.text! ?? ""
                text = text + " - 喜欢 \(likeNum)"
            self.detailLabel.text = text
        }
        
    }
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(currentContext, UIColor.grayColor().CGColor)
        CGContextSetLineWidth(currentContext, 1)
        CGContextMoveToPoint(currentContext, 10, CGRectGetHeight(self.frame))
        CGContextAddLineToPoint(currentContext, CGRectGetWidth(self.frame) - 10, CGRectGetHeight(self.frame))
        
        CGContextSetLineDash(currentContext, 0, [4, 2], 2)
        
        CGContextStrokePath(currentContext)
    }
}
