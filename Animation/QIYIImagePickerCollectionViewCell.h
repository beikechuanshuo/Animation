//
//  QIYIImagePickerCollectionViewCell.h
//  ITest
//
//  Created by iqiyi on 16/6/28.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIYIImagePickerManager.h"

@class QIYIImagePickerCollectionViewCellModel;
@class QIYIImagePickerCollectionViewCell;

@protocol QIYIImagePickerCollectionViewCellDelegate <NSObject>

- (void)cell:(QIYIImagePickerCollectionViewCell *)cell tapedView:(UIView *)view;

- (void)cell:(QIYIImagePickerCollectionViewCell *)cell tapedSelectView:(UIView *)view;

@end

@interface QIYIImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) QIYIImagePickerCollectionViewCellModel *model;

@property (nonatomic, weak) id<QIYIImagePickerCollectionViewCellDelegate>delegate;

@property (nonatomic, assign) BOOL isGif;

@property (nonatomic, strong) UILabel *selectIndexLabel;

@end


@interface QIYIImagePickerCollectionViewCellModel : NSObject

@property (nonatomic, strong) id asset;
@property (nonatomic, assign) QIYIImagePickerCollectionViewCellSelectStatus status;
@property (nonatomic, assign) NSInteger tag;

@end
