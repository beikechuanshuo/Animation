//
//  PhotoCollectionViewCell.h
//  Animation
//
//  Created by liyanjun on 2018/3/19.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoModel;

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) PhotoModel *model;

@end


@interface PhotoModel : NSObject

@property (nonatomic, copy) NSString *photoName;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) id asset;

@end
