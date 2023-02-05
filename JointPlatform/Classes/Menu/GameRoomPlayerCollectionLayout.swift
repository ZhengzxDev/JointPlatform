//
//  GameRoomPLayerCollectionLayout.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/13.
//

import UIKit


class GameRoomPlayerCollectionLayout:UICollectionViewFlowLayout{
    fileprivate var attributesArr:[UICollectionViewLayoutAttributes] = []
    
    public var numOfItemPerRow:CGFloat = 2
    
    public var numOfItemPerCol:CGFloat = 2
    
    /// 0 = left
    /// 1 = right
    /// 2 = center
    public var alignDirection:Int = 0
    
    override var collectionViewContentSize: CGSize{
        
        let availableHeight = collectionView!.bounds.height - sectionInset.top - sectionInset.bottom - (numOfItemPerCol-1) * minimumLineSpacing
        let itemHeight = availableHeight / numOfItemPerCol
        
        let itemCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        let layoutRowCount:Int =  Int(ceil(CGFloat(itemCount) / CGFloat(numOfItemPerRow)))
        let layoutHeight:CGFloat = CGFloat(layoutRowCount) * itemHeight + sectionInset.top + sectionInset.bottom + CGFloat(layoutRowCount-1)*minimumLineSpacing
 
        return CGSize(width: collectionView!.bounds.width, height: layoutHeight)
        
    }
    
    
    override func prepare() {
        super.prepare()
        
        attributesArr = []
        
        let availableHeight = collectionView!.bounds.height - sectionInset.top - sectionInset.bottom - (numOfItemPerCol-1) * minimumLineSpacing
        
        let availableWidth = collectionView!.bounds.width - sectionInset.left - sectionInset.right - (numOfItemPerRow-1) * minimumInteritemSpacing
        
        let itemHeight = availableHeight / numOfItemPerCol
        let itemWidth = availableWidth / numOfItemPerRow
        
        var startY = sectionInset.top
        
        for index in 0 ..< collectionView!.numberOfItems(inSection: 0){
            let indexPath = IndexPath(row: index, section: 0)
            if index % Int(numOfItemPerRow) == 0 && index != 0 {
                startY += itemHeight + minimumLineSpacing
            }
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: index % Int(numOfItemPerRow) == 0 ? sectionInset.left : sectionInset.left + itemWidth + minimumInteritemSpacing, y: startY, width: itemWidth, height: itemHeight)
            
            attributes.frame = frame
            attributesArr.append(attributes)
        }
        
    }
    
    // 获取 Cell 视图的布局，要重写【在移动/删除的时候会调用该方法】
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArr.filter({ $0.indexPath == indexPath && $0.representedElementCategory == .cell }).first
    }
    
    // 获取 SupplementaryView 视图的布局
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArr.filter({ $0.indexPath == indexPath && $0.representedElementKind == elementKind }).first
    }
    
    // 此方法应该返回当前屏幕正在显示的视图的布局属性集合，要重写
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArr.filter({ rect.intersects($0.frame) })
    }
}
