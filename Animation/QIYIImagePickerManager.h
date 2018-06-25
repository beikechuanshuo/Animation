//
//  QIYIImagePickerManager.h
//  ITest
//
//  Created by iqiyi on 16/6/30.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LineColor [HEX_COLOR(0x979797) colorWithAlphaComponent:0.5]

typedef NS_ENUM(NSInteger,QIYIImagePickerCollectionViewCellSelectStatus)
{
    QIYIImagePickerCollectionViewCellSelectStatus_Normal = 0,
    QIYIImagePickerCollectionViewCellSelectStatus_Selected = 1,
};

typedef NS_ENUM(NSInteger,PushAnimationOrientation)
{
    PushAnimationOrientation_Left = 0,
    PushAnimationOrientation_Right,
    PushAnimationOrientation_Top,
    PushAnimationOrientation_Bottom,
};

@interface QIYIImagePickerManager : NSObject

//单例
+ (instancetype)sharedInstance;

//获取选中图片数组
- (NSMutableArray *)getSelectedPhotos;

//判断照片是否已经选中
- (BOOL)isSelectedPhotos:(id)asset;

//增加选中的照片
- (void)addAssetToSelectedPhotos:(id)asset;

//移除选中的照片
- (void)removeAssetFromSelectedPhotos:(id)asset;

//选中的照片数目
- (NSInteger)selectedPhotosCount;

//移除所有选中的照片
- (void)removeAllSelectedPhtots;

//跳动的动画
- (void)animation1WithView:(UIView *)view finishBlock:(void(^)(void))finishBlock;

//Push动画
- (void)animationPushWithView:(UIView *)view pushAnimationOrientation:(PushAnimationOrientation)orientation finishBlock:(void(^)(void))finishBlock;


@end

