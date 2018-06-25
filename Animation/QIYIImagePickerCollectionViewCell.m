//
//  QIYIImagePickerCollectionViewCell.m
//  ITest
//
//  Created by iqiyi on 16/6/28.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import "QIYIImagePickerCollectionViewCell.h"
#import <Photos/Photos.h>
#import "Define.h"

@interface QIYIImagePickerCollectionViewCell ()
{
    QIYIImagePickerCollectionViewCellModel *_model;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectView;
@property (nonatomic, strong) UILabel *gifView;
@property (nonatomic, assign) BOOL isImage; //是否是图片
@property (nonatomic, strong) UIImageView *bottomVideoContainerView;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation QIYIImagePickerCollectionViewCell

@dynamic model;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
        [self addGestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
   
}

- (void)initUI
{
    self.backgroundColor = [UIColor lightGrayColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.tag = 1000;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    [self addSubview:self.imageView];
    
    self.selectView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-27, 2, 25, 25)];
    self.selectView.backgroundColor = [UIColor clearColor];
    self.selectView.userInteractionEnabled = YES;
    self.selectView.contentMode = UIViewContentModeCenter;
    self.selectView.tag = 1001;
    [self addSubview:self.selectView];
    
    self.selectIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.selectIndexLabel.backgroundColor = [UIColor clearColor];
    self.selectIndexLabel.textColor = [UIColor whiteColor];
    self.selectIndexLabel.font = [UIFont systemFontOfSize:15];
    self.selectIndexLabel.textAlignment = NSTextAlignmentCenter;
    [self.selectView addSubview:self.selectIndexLabel];
    
    self.gifView =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-30, CGRectGetHeight(self.frame)-18, 30, 18)];
    self.gifView.backgroundColor = kThemeColor;
    self.gifView.tag = 1002;
    self.gifView.textAlignment = NSTextAlignmentCenter;
    self.gifView.text = @"GIF";
    self.gifView.font = [UIFont systemFontOfSize:13];
    self.gifView.textColor = [UIColor whiteColor];
    self.gifView.adjustsFontSizeToFitWidth = YES;
    self.gifView.hidden = YES;
    [self addSubview:self.gifView];
}

//增加手势
- (void)addGestureRecognizer
{
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.imageView addGestureRecognizer:imageViewTap];
    
    UITapGestureRecognizer *selectViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.selectView addGestureRecognizer:selectViewTap];
}

- (void)setModel:(QIYIImagePickerCollectionViewCellModel *)model
{
    _model = model;
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
    
    NSString *string = [model.asset valueForKey:@"filename"];
    if ([string hasSuffix:@"gif"] || [string hasSuffix:@"GIF"]||[string hasSuffix:@"Gif"])
    {
        self.gifView.hidden = NO;
        self.isGif = YES;
    }
    else
    {
        self.gifView.hidden = YES;
        self.isGif = NO;
    }
    
    if(((PHAsset *)model.asset).mediaType == PHAssetMediaTypeImage)
    {
        self.isImage = YES;
    }
    else
    {
        self.isImage = NO;
    }
    
    NSUInteger width = ((PHAsset *)model.asset).pixelWidth;
    NSUInteger height = ((PHAsset *)model.asset).pixelHeight;
    
    CGSize targetSize = CGSizeMake(160,160*height/width);
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
    
    if (model.status == QIYIImagePickerCollectionViewCellSelectStatus_Normal)
    {
        self.selectIndexLabel.text = @"";
        self.selectView.image = [UIImage imageNamed:@"unselectwithcheck"];
    }
    else
    {
        self.selectView.image = [UIImage imageNamed:@"selected"];
        NSMutableArray *array = [[QIYIImagePickerManager sharedInstance] getSelectedPhotos];
        
        NSInteger index = -1;
        
        for (PHAsset *temAsset in array)
        {
            NSInteger temIndex = [array indexOfObject:temAsset];
            
            NSString *id1 = ((PHAsset *)temAsset).localIdentifier;
            NSString *id2 = ((PHAsset *)model.asset).localIdentifier;
            
            if ([id1 isEqualToString:id2])
            {
                index = temIndex;
                break;
            }
        };
        
        self.selectIndexLabel.text = [NSString stringWithFormat:@"%ld",(long)(index+1)];
    }
}

- (QIYIImagePickerCollectionViewCellModel *)model
{
    return _model;
}

//处理tap手势
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if (self.isImage == NO)
        {
            return;
        }
        if (tapGesture.view.tag == 1000)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cell:tapedView:)])
            {
                [self.delegate cell:self tapedView:tapGesture.view];
            }
        }
        else if (tapGesture.view.tag == 1001)
        {
            if (self.model.status == QIYIImagePickerCollectionViewCellSelectStatus_Normal)
            {
                //添加到选中照片
                [[QIYIImagePickerManager sharedInstance] addAssetToSelectedPhotos:self.model.asset];
                self.model.status = QIYIImagePickerCollectionViewCellSelectStatus_Selected;
                //动画效果
                WS
                [[QIYIImagePickerManager sharedInstance] animation1WithView:self.selectView finishBlock:^{
                    SS
                    self.selectView.image = [UIImage imageNamed:@"selected"];
                }];
            }
            else if(self.model.status == QIYIImagePickerCollectionViewCellSelectStatus_Selected)
            {
                //移除选中的照片
                [[QIYIImagePickerManager sharedInstance] removeAssetFromSelectedPhotos:self.model.asset];
                self.model.status = QIYIImagePickerCollectionViewCellSelectStatus_Normal;
                
                //动画效果
                WS
                [[QIYIImagePickerManager sharedInstance] animation1WithView:self.selectView finishBlock:^{
                    SS
                    self.selectView.image = [UIImage imageNamed:@"unselectwithcheck"];
                }];
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(cell:tapedSelectView:)])
            {
                [self.delegate cell:self tapedSelectView:tapGesture.view];
            }
        }
    }
}

- (NSString *)getVideoDurationStringWithDuration:(long long)duration
{
    NSUInteger hour = (NSUInteger)(duration/(60*60));
    NSUInteger minute = (NSUInteger)((duration - (hour*60*60))/60);
    NSUInteger second = (NSUInteger)((duration - (hour*60*60))-(minute*60));
    
    NSString *durationString = nil;
    if (hour > 0)
    {
        //有小时数
        durationString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(unsigned long)hour,(unsigned long)minute,(unsigned long)second];
    }
    else
    {
        durationString  = [NSString stringWithFormat:@"%02ld:%02ld",(unsigned long)minute,(unsigned long)second];
    }
    
    return durationString;
}

@end

@implementation QIYIImagePickerCollectionViewCellModel

@synthesize asset,status,tag;

@end
