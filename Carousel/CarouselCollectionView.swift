//
//  CarouselCollectionView.swift
//  reuseTest
//
//  Created by wanwu on 17/3/28.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

///获取indexPath 一定要调用realCurrentIndexPath
class CarouselCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    class _CarouselCollectionViewDataSourceProxy: CommonProxy, UICollectionViewDataSource {
        weak var obj: CarouselCollectionView!
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return obj.collectionView(collectionView, numberOfItemsInSection: section)
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return obj.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    class _CarouselCollectionViewDelegateProxy: CommonProxy, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    }
    
    var increaseRow = 1
    
    lazy var timer: Timer = {
        let t = Timer.scheduledTimer(self.timing, action: { [unowned self] (t) in
            if self.itemCount <= 0 {
                return
            }
            let idx = IndexPath(row: self.currentIndexPath.row + self.increaseRow, section: self.currentIndexPath.section)
            self.currentIndexPath = idx
            self.scrollToItem(at: idx, at: self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically, animated: true)
            self.pageControl.currentPage = self.currentIndexPath.row % self.itemCount
            }, userInfo: nil, repeats: true)
        
        return t
    } ()
    var timing: TimeInterval = 4.0
    
    weak fileprivate var originalDataSource: UICollectionViewDataSource?
    weak fileprivate var originalDelegate: UICollectionViewDelegate?
    fileprivate var realSize = 0
    fileprivate var itemCount = 0
    fileprivate var isSetupedPosition = false
    
    fileprivate var currentIndexPath = IndexPath(row: 0, section: 0)
    
    fileprivate var dataSourceProxy: _CarouselCollectionViewDataSourceProxy?
    fileprivate var delegateProxy: _CarouselCollectionViewDelegateProxy?
    
    var pageControl = UIPageControl()
    var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
            }
        }
    }
    
    ///当前page
    var realCurrentIndexPath: IndexPath {
        get {
            return IndexPath(row: currentIndexPath.row % itemCount, section: 0)
        }
    }
    
    override var dataSource: UICollectionViewDataSource? {
        didSet {
            originalDataSource = dataSource
            dataSourceProxy = dataSource == nil ? nil : _CarouselCollectionViewDataSourceProxy(delegate: dataSource, commonDelegate: self)
            dataSourceProxy?.obj = self
            super.dataSource = dataSourceProxy
        }
    }
    
    override var delegate: UICollectionViewDelegate? {
        didSet {
            originalDelegate = delegate
            delegateProxy = delegate == nil ? nil : _CarouselCollectionViewDelegateProxy(delegate: delegate, commonDelegate: self)
            super.delegate = delegateProxy
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = scrollDirection
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "placehodertmpcell")
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        ///设置 页码
        pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.maxY - 25, width: self.frame.width, height: 20))
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        timer.fireDate = Date().addingTimeInterval(self.timing)
        self.superview?.addSubview(pageControl)
        //        self.isPagingEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pageControl.frame = CGRect(x: 0, y: self.frame.maxY - 25, width: self.frame.width, height: 20)
    }
    
    override func reloadData() {
        super.reloadData()
        isSetupedPosition = false
    }
    
    func resetAnimation() {
        let x = self.contentOffset.x
        let y = self.contentOffset.y
        if let indexPath = self.indexPathForItem(at: CGPoint(x: x + bounds.width / 2, y: y + bounds.height / 2)) {
            currentIndexPath = indexPath
            pageControl.currentPage = currentIndexPath.row % itemCount
            if !self.isPagingEnabled {
                //                goToIndex(idx: IndexPath(item: indexPath.row % self.itemCount, section: 0))
                //                return
                if let cell = self.cellForItem(at: indexPath) {
                    let destinationX = scrollDirection == .horizontal ? cell.center.x - bounds.width / 2 : x
                    
                    let destinationY = scrollDirection == .vertical ? cell.center.y - bounds.height / 2 : y
                    self.setContentOffset(CGPoint(x: destinationX, y: destinationY), animated: true)
                    
                }
            }
            
        }
    }
    
    fileprivate func goToIndex(idx: IndexPath) {
        super.scrollToItem(at: idx, at: scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically, animated: false)
        pageControl.currentPage = currentIndexPath.row % itemCount
        currentIndexPath = idx
        pageControl.currentPage = currentIndexPath.row % itemCount
    }
    
    deinit {
        timer.invalidate()
        print("轮播图 销毁")
    }
}

extension CarouselCollectionView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let od = originalDataSource, !od.isEqual(self) {
            if let count = originalDataSource?.collectionView(collectionView, numberOfItemsInSection: section) {
                realSize = count * (count > 100 || self.isPagingEnabled ? 4 : 100)
                itemCount = count
            }
        }
        
        pageControl.numberOfPages = itemCount
        return realSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let realIndex = IndexPath(row: indexPath.row % itemCount, section: indexPath.section)
        if let od = originalDataSource, !od.isEqual(self) {
            if let cell = originalDataSource?.collectionView(collectionView, cellForItemAt: realIndex) {
                return cell
            }
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "placehodertmpcell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let d = originalDelegate as? UICollectionViewDelegateFlowLayout, !d.isEqual(self) {
            return d.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? collectionView.bounds.size
        }
        
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let d = originalDelegate as? UICollectionViewDelegateFlowLayout, !d.isEqual(self) {
            return d.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let d = originalDelegate as? UICollectionViewDelegateFlowLayout, !d.isEqual(self) {
            return d.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? 0
        }
        return 0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let d = originalDelegate, !d.isEqual(self) {
            d.scrollViewWillBeginDragging?(scrollView)
        }
        if !isSetupedPosition {
            goToIndex(idx: IndexPath(item: realSize / 2, section: 0))
        } else {
            goToIndex(idx: IndexPath(item: realSize / 2 + currentIndexPath.row % self.itemCount, section: 0))
        }
        isSetupedPosition = true
        self.timer.fireDate = Date.distantFuture
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let d = originalDelegate, !d.isEqual(self) {
            d.scrollViewDidEndScrollingAnimation?(scrollView)
        }
        
        goToIndex(idx: IndexPath(item: realSize / 2 + currentIndexPath.row % self.itemCount, section: 0))
        self.timer.fireDate = Date().addingTimeInterval(timing)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let d = originalDelegate, !d.isEqual(self) {
            d.scrollViewDidEndDecelerating?(scrollView)
        }
        resetAnimation()
        self.timer.fireDate = Date().addingTimeInterval(timing)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let d = originalDelegate, !d.isEqual(self) {
            d.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            let v = scrollView.panGestureRecognizer.velocity(in: scrollView)
            let speed = layout.scrollDirection == .horizontal ? v.x : v.y
            
            if abs(speed) < 200 {
                resetAnimation()
            }
        }
    }
    
}


















