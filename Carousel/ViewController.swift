//
//  ViewController.swift
//  Carousel
//
//  Created by wanwu on 17/3/30.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var carouselView: CarouselCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        carouselView.delegate = self
        carouselView.dataSource = self
        //修改此处，，改变滚动方向
        carouselView.scrollDirection = .horizontal
    }

    //MARK: 代理
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TestCollectionViewCell
        cell.imgView.image = UIImage(named: "\(indexPath.row + 1)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MARK: 必须用 realCurrentIndexPath才是准确的
        print(carouselView.realCurrentIndexPath)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 200, height: 150)
//    }
    
    
    @IBAction func ac_vertical(_ sender: Any) {
        carouselView.scrollDirection = .vertical
    }
    
    @IBAction func ac_horizontal(_ sender: Any) {
        carouselView.scrollDirection = .horizontal
    }
    
    var flag = false
    @IBAction func ac_pagge(_ sender: UIButton) {
        flag = !flag
        carouselView.isPagingEnabled = flag
        sender.setTitle(flag ? "分页关" : "分页", for: .normal)
    }
    
    
    
}

