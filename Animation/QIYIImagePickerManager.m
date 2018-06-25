//
//  QIYIImagePickerManager.m
//  ITest
//
//  Created by iqiyi on 16/6/30.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import "QIYIImagePickerManager.h"
#import <Photos/Photos.h>

@interface QIYIImagePickerManager ()

//选中照片数组
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end

@implementation QIYIImagePickerManager

#pragma mark 编辑过的照片信息字典 用该照片的唯一标示符作为key

+ (instancetype)sharedInstance
{
    static QIYIImagePickerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QIYIImagePickerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.selectedPhotos = [[NSMutableArray alloc] init];
    }
    return self;
}

//获取选中图片数组
- (NSMutableArray *)getSelectedPhotos
{
    return self.selectedPhotos;
}

//判断照片是否已经选中
- (BOOL)isSelectedPhotos:(id)asset
{
    if (asset == nil)
    {
        return NO;
    }
    
    BOOL ret = NO;
    if ([asset isKindOfClass:[PHAsset class]])
    {
        for (PHAsset *temAsset in self.selectedPhotos)
        {
            NSString *id1 = ((PHAsset *)temAsset).localIdentifier;
            NSString *id2 = ((PHAsset *)asset).localIdentifier;
            
            if ([id1 isEqualToString:id2])
            {
                ret = YES;
                break;
            }
        };
    }

    return ret;
}

//增加选中的照片
- (void)addAssetToSelectedPhotos:(id)asset
{
    if (asset == nil)
    {
        return;
    }
    
    if ([self isSelectedPhotos:asset])
    {
        return;
    }
    
    [self.selectedPhotos addObject:asset];
}

//移除选中的照片
- (void)removeAssetFromSelectedPhotos:(id)asset
{
    if (asset == nil)
    {
        return;
    }
    
    BOOL ret = [self isSelectedPhotos:asset];
    if (ret)
    {
        if ([asset isKindOfClass:[PHAsset class]])
        {
            for (PHAsset *temAsset in self.selectedPhotos)
            {
                NSString *id1 = ((PHAsset *)temAsset).localIdentifier;
                NSString *id2 = ((PHAsset *)asset).localIdentifier;
                
                if ([id1 isEqualToString:id2])
                {
                    [self.selectedPhotos removeObject:temAsset];
                    break;
                }
            };
        }
    }
}

//选中的照片数目
- (NSInteger)selectedPhotosCount
{
    return self.selectedPhotos.count;
}

//移除所有选中的照片
- (void)removeAllSelectedPhtots
{
    [self.selectedPhotos removeAllObjects];
}

//跳动动画
- (void)animation1WithView:(UIView *)view finishBlock:(void(^)(void))finishBlock
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.3;
        
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        animation.values = values;
        [view.layer addAnimation:animation forKey:nil];
    } completion:^(BOOL finished) {
        finishBlock();
    }];
}

//Push动画
- (void)animationPushWithView:(UIView *)view pushAnimationOrientation:(PushAnimationOrientation)orientation finishBlock:(void(^)(void))finishBlock
{
    [UIView animateWithDuration:0.35 animations:^{
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.35];
        [animation setType:kCATransitionPush];
        
        switch (orientation)
        {
            case PushAnimationOrientation_Left:
                [animation setSubtype:kCATransitionFromLeft];
                break;
            case PushAnimationOrientation_Right:
                [animation setSubtype:kCATransitionFromRight];
                break;
            case PushAnimationOrientation_Top:
                [animation setSubtype:kCATransitionFromTop];
                break;
            case PushAnimationOrientation_Bottom:
                [animation setSubtype:kCATransitionFromBottom];
                break;
            default:
                [animation setSubtype:kCATransitionFromBottom];
                break;
        }
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[view layer] addAnimation:animation forKey:@"SwitchToView"];
    } completion:^(BOOL finished) {
        finishBlock();
    }];
}

@end

