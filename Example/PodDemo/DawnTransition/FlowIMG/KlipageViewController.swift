//
//  KlipageViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit
import DawnTransition

class KlipageViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataList: [KlipageModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupGestures()
        commonInitialization()
        dataUpdates()
    }
    
    private func setupGestures() {
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
    
    func commonInitialization() {
        let layout = UICollectionViewWaterfallLayout.init()
        layout.columnCount = 2
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 15
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: UIScreen.safeInsets.top, left: 0, bottom: 20, right: 0)
        collectionView.register(cellWithClass: AlipageCell.self)
        view.addSubview(collectionView)
        collectionView.dw.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func dataUpdates() {
        let imgs = KliPageSnapshotCache.shared.cacheImages
        DispatchQueue.asyncAfter(delay: 0.25) {
            let array = imgs
            let values = array.map { s in
                return KlipageModel(tit: "title", imag: s)
            }
            self.dataList = values
            self.collectionView.reloadData()
        }
    }
}

extension KlipageViewController: UICollectionViewDelegateWaterfallLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let model = dataList?[indexPath.item] else { return .zero }
        let image = model.takeImage()
        let equ = CGHorizontalEquantLayout1(count: 2, leadSpacing: 20, tailSpacing: 20)
        let eWidth = equ.equalWidthThatFits(20)
        let scale = image.size.width / image.size.height
        let eHeight = eWidth / scale
        return CGSize(width: eWidth, height: eHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        let equ = CGHorizontalEquantLayout1(count: 2, leadSpacing: 20, tailSpacing: 20)
        return UIEdgeInsets(top: 0, left: equ.leadSpacing, bottom: 0, right: equ.tailSpacing)
    }
}

extension KlipageViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AlipageCell.self, for: indexPath)
        cell.contentView.backgroundColor = .yellow
        cell.model = dataList?[indexPath.item]
        return cell
    }
}

extension KlipageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AlipageCell else { return }
        guard let model = dataList?[indexPath.item] else { return }
        let vc = LagerImageController()
        vc.ccimage = model.takeImage()
        vc.dawn.isModalEnabled = true
        let pathway = DawnAnimationDissolve(sourceView: cell.contentView)
        pathway.duration = 0.375
        vc.dawn.transitionCapable = pathway
        self.present(vc, animated: true, completion: nil)
    }
}

private class LagerImageController: UIViewController {

    var lagerImageView: UIImageView!
    var ccimage: UIImage? {
        didSet {
            lagerImageView?.image = ccimage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        lagerImageView = UIImageView()
        lagerImageView.backgroundColor = .white
        lagerImageView.contentMode = .scaleAspectFit
        lagerImageView.image = ccimage
        view.addSubview(lagerImageView)
        view.layer.masksToBounds = true
        
        let targetSize = ccimage?.sizeOfScaled(width: view.bounds.width) ?? .zero
        lagerImageView.dw.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(targetSize.width)
            make.height.equalTo(targetSize.height)
        }
        
        lagerImageView.addTapGesture { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        setupGestures()
    }
    
    private func setupGestures() {
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}
