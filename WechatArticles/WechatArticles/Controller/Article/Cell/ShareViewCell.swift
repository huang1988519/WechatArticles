//
//  ShareViewCell.swift
//  WechatArticle
//
//  Created by hwh on 15/11/22.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit

class ShareViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
    }

}
