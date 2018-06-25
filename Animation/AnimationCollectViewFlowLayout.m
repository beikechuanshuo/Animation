//
//  AnimationCollectViewFlowLayout.m
//  Animation
//
//  Created by liyanjun on 2018/3/19.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import "AnimationCollectViewFlowLayout.h"

@implementation AnimationCollectViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if ([self.collectionView numberOfItemsInSection:0] > 2)
    {
        NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
        CGFloat contentOffsetX = self.collectionView.contentOffset.x;
        CGFloat collectionViewCenterX = self.collectionView.frame.size.width * 0.5;
        for (UICollectionViewLayoutAttributes *attr in attrs)
        {
            CGFloat scale = 1 - fabs(attr.center.x - contentOffsetX - collectionViewCenterX) / self.collectionView.bounds.size.width;
            attr.transform = CGAffineTransformMakeScale(scale, scale);
        }
        return attrs;
    }
    else
    {
        return [super layoutAttributesForElementsInRect:rect];
    }
}

@end
