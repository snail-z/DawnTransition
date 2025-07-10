//
//  UICollectionViewDistanceBetweenLayout.m
//  ESCCBusiness
//
//  Created by zhang on 2022/9/22.
//

#import "UICollectionViewDistanceBetweenLayout.h"

@implementation UICollectionViewDistanceBetweenLayout
- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _distanceBetweenPages = 20;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = self.collectionView.bounds.size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttsArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat halfWidth = self.collectionView.bounds.size.width / 2.0;
    CGFloat centerX = self.collectionView.contentOffset.x + halfWidth;
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(obj.center.x + (obj.center.x - centerX) / halfWidth * self.distanceBetweenPages / 2, obj.center.y);
    }];
    return layoutAttsArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
