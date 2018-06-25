//
//  PhotoCollectionViewCell.m
//  Animation
//
//  Created by liyanjun on 2018/3/19.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "Define.h"
#import "UIView+YYAdd.h"
#import <Photos/Photos.h>

@interface  PhotoCollectionViewCell()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UILabel *indexLabel;

@property (strong, nonatomic) CALayer *photoFrameLayer;

@end

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.imageView.layer.cornerRadius = 10.0;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height-30, self.width, 20)];
    self.indexLabel.backgroundColor = [UIColor clearColor];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.indexLabel];
    
    self.photoFrameLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.layer addSublayer:self.photoFrameLayer];
}

- (CALayer *)photoFrameLayer
{
    if (_photoFrameLayer == nil)
    {
        _photoFrameLayer = [CALayer layer];
    }
    
    return _photoFrameLayer;
}

- (void)setModel:(PhotoModel *)model
{
    _model = model;
    
    if (model && model.photoName.length > 0)
    {
        UIImage *image = [UIImage imageNamed:model.photoName];
        
        if (image)
        {
            self.imageView.image = image;
        }
    }
    else if(model && model.asset != nil)
    {
        PHImageManager *imageManager = [PHImageManager defaultManager];
        static PHImageRequestOptions *imageRequestOptions;
        if (!imageRequestOptions)
        {
            imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            imageRequestOptions.synchronous = NO;
            imageRequestOptions.networkAccessAllowed = NO;
        }
        
        NSUInteger width = ((PHAsset *)model.asset).pixelWidth;
        NSUInteger height = ((PHAsset *)model.asset).pixelHeight;

        CGSize targetSize = CGSizeMake(SCREEN_WIDTH,SCREEN_WIDTH*height/width);
        WS
        [imageManager requestImageForAsset:(PHAsset *)model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            SS
            if (result)
            {
                self.imageView.image = result;
            }
            else
            {
                self.imageView.image = nil;
            }
        }];
    }
    
     self.indexLabel.text = [NSString stringWithFormat:@"%ld",(long)(model.index+1)];
    
    int ran = (arc4random()%8)+1;
    NSString *imageName = [NSString stringWithFormat:@"%02d.png",ran];
    UIImage *image = [UIImage imageNamed:imageName];
    [self.photoFrameLayer setContents:(id)image.CGImage];
}

@end


@implementation PhotoModel

@end

