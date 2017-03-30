//
//  TestCollectionViewCell.swift
//  reuseTest
//
//  Created by wanwu on 17/3/28.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = UIColor(red: CGFloat(arc4random() % 100) / 100, green: CGFloat(arc4random() % 100) / 100, blue: CGFloat(arc4random() % 100) / 100, alpha: 1)
    }

}
