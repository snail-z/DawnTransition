//
//  UICollectionViewPinToVisibleLayout.h
//  ESCCBusiness
//
//  Created by zhang on 2022/9/23.
//

#import "UICollectionViewLeftAlignedLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewPinToVisibleLayout : UICollectionViewLeftAlignedLayout

/** 在该索引及之后的分组头会被悬停 */
@property (nonatomic, assign) NSInteger pinToVisibleAfterIndex;

@end

NS_ASSUME_NONNULL_END
