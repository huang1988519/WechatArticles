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
    @IBOutlet weak var ttitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
