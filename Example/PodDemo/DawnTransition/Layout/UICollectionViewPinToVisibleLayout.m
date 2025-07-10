//
//  UICollectionViewPinToVisibleLayout.m
//  ESCCBusiness
//
//  Created by zhang on 2022/9/23.
//

#import "UICollectionViewPinToVisibleLayout.h"

@implementation UICollectionViewPinToVisibleLayout

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [NSMutableArray arrayWithArray:originalAttributes];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSNumber *,UICollectionViewLayoutAttributes *> *lastCells = [NSMutableDictionary dictionary];
    [updatedAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [obj indexPath];
        if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            headers[@(indexPath.section)] = obj;
            obj.zIndex = 1029;
        } else if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            obj.zIndex = 1;
        } else {
            obj.zIndex = 1;
            UICollectionViewLayoutAttributes *currentAttribute = lastCells[@(indexPath.section)];
            if (!currentAttribute || indexPath.row > currentAttribute.indexPath.row) {
                [lastCells setObject:obj forKey:@(indexPath.section)];
            }
        }
    }];

    [lastCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UICollectionViewLayoutAttributes *obj, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = obj.indexPath;
        NSNumber *indexPathKey = @(indexPath.section);
        UICollectionViewLayoutAttributes *headerAttributes = headers[indexPathKey];
        if (!headerAttributes) {
            headerAttributes = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          atIndexPath:[NSIndexPath indexPathForItem:0 inSection:key.integerValue]];
            if (!CGSizeEqualToSize(CGSizeZero, headerAttributes.frame.size)) {
                if (indexPath.section >= self.pinToVisibleAfterIndex) {
                    [updatedAttributes addObject:headerAttributes];
                }
            }
        }
    }];
    return updatedAttributes;
}

- (void)updateHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes
            lastCellAttributes:(UICollectionViewLayoutAttributes *)lastCellAttributes {
    CGRect currentBounds = self.collectionView.bounds;
    CGPoint origin = attributes.frame.origin;
    CGFloat sectionMaxY = CGRectGetMaxY(lastCellAttributes.frame) - CGRectGetHeight(attributes.frame) + self.sectionInset.top;
    CGFloat y = CGRectGetMinY(currentBounds) + self.collectionView.contentInset.top;
    CGFloat originY = MIN(MAX(y, attributes.frame.origin.y), sectionMaxY);
    origin.y = originY;
    attributes.frame = (CGRect){origin, attributes.frame.size};
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

@end
