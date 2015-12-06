//
//  Cus+SpringImageView.swift
//  WechatArticle
//
//  Created by hwh on 15/11/19.
//  Copyright © 2015年 hwh. All rights reserved.
//

import UIKit
//import Spring
class Cus_SpringView: SpringView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 6
    }
}
