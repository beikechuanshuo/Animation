//
//  QIYIImageAlbumsView.m
//  ITest
//
//  Created by iqiyi on 16/6/29.
//  Copyright © 2016年 iqiyi. All rights reserved.
//

#import "QIYIImageAlbumsView.h"
#import "HDevice.h"
#import <Photos/Photos.h>
#import "Define.h"

#define CancelBtnWidth 60

#define LineSpacing 0.5

static NSString *QIYIImageAlbumsTableViewCellReuserIdentifier = @"QIYIImageAlbumsTableViewCellReuserIdentifier";

@class QIYIImageAlbumsViewCell;

@interface QIYIImageAlbumsView ()<UITableViewDelegate,UITableViewDataSource>

//顶部控件
@property (nonatomic, strong) UIView *topView;

//取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;

//title
@property (nonatomic, strong) UILabel *titleView;

//相册显示控件
@property (nonatomic, strong) UITableView *albumsTableView;

@end

@implementation QIYIImageAlbumsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    
    return self;
}

//初始化
- (void)initUI
{
    self.backgroundColor = HEX_COLOR(0xF0F0F0);
    
    CGFloat navHeight = 64;
    if ([HDevice shareInstance].localizedModel == HDeviceLocalizedModel_iPhoneX)
    {
        navHeight = 88;
    }
    
    //顶部控件
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), navHeight)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topView];
    
    //顶部控件细线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame)-0.5, CGRectGetWidth(self.topView.frame), 0.5)];
    topLine.backgroundColor = LineColor;
    [self.topView addSubview:topLine];
    
    //取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(CGRectGetMaxX(self.topView.frame) - CancelBtnWidth, navHeight-44, CancelBtnWidth,44);
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.topView addSubview:self.cancelBtn];
    
    //title
    self.titleView = [[UILabel alloc] initWithFrame:CGRectMake(CancelBtnWidth, navHeight - 44, CGRectGetWidth(self.topView.frame)-CancelBtnWidth*2,44)];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.textColor = [UIColor blackColor];
    self.titleView.font = [UIFont boldSystemFontOfSize:18];
    self.titleView.text = @"所有相册";
    [self.topView addSubview:self.titleView];
    
    //相册
    self.albumsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame)+LineSpacing, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(self.topView.frame)-LineSpacing*2) style:UITableViewStylePlain];
    self.albumsTableView.backgroundColor = HEX_COLOR(0xF0F0F0);
    self.albumsTableView.delegate = self;
    self.albumsTableView.dataSource = self;
    self.albumsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.albumsTableView registerClass:[QIYIImageAlbumsViewCell class] forCellReuseIdentifier:QIYIImageAlbumsTableViewCellReuserIdentifier];
    [self addSubview:self.albumsTableView];
}

#pragma mark -
- (void)setAlbumsArray:(NSMutableArray *)albumsArray
{
    _albumsArray = albumsArray;
    
    if (albumsArray)
    {
        //更新数据
        WS
        dispatch_async(dispatch_get_main_queue(), ^{
            SS
            [self.albumsTableView reloadData];
        });
    }
}

- (void)reloadDataSource
{
    WS
    dispatch_async(dispatch_get_main_queue(), ^{
        SS
        [self.albumsTableView reloadData];
    });
}

#pragma mark - 按钮事件 -
- (void)cancelAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageAlbumsView:tapedCancelButton:)])
    {
        [self.delegate imageAlbumsView:self tapedCancelButton:sender];
    }
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QIYIImageAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QIYIImageAlbumsTableViewCellReuserIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[QIYIImageAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QIYIImageAlbumsTableViewCellReuserIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.model = self.albumsArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = self.albumsArray[indexPath.row];

    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)model options:nil];
    if (fetchResult.count == 0)
    {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageAlbumsView:selectedIndexPath:)])
    {
        [self.delegate imageAlbumsView:self selectedIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

@end

#define Spacing 10

#define AccessViewWidth 15

@interface QIYIImageAlbumsViewCell ()

@property (nonatomic, strong) UIImageView *posterView;

@property (nonatomic, strong) UILabel *albumNameView;

@property (nonatomic, strong) UIImageView *accessView;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation QIYIImageAlbumsViewCell

- (void)drawRect:(CGRect)rect
{
    //相册封面
    self.posterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    self.posterView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterView.backgroundColor = [UIColor whiteColor];
    self.posterView.layer.masksToBounds = YES;
    [self addSubview:self.posterView];
    
    self.albumNameView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.posterView.frame)+Spacing, 0, CGRectGetWidth(self.frame)-(CGRectGetMaxX(self.posterView.frame)+Spacing)-35, CGRectGetHeight(self.frame))];
    self.albumNameView.backgroundColor = [UIColor whiteColor];
    self.albumNameView.textColor = [UIColor blackColor];
    self.albumNameView.font = [UIFont systemFontOfSize:17];
    self.albumNameView.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.albumNameView];
    
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-0.5, CGRectGetWidth(self.frame), 0.5)];
    self.bottomLineView.backgroundColor = LineColor;
    [self addSubview:self.bottomLineView];
}

- (void)setModel:(id)model
{
    _model = model;
    
    if (model)
    {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)model options:nil];
        if (fetchResult && fetchResult.count > 0)
        {
            //获取最后一张照片当作封面
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
            
            NSUInteger width = ((PHAsset *)fetchResult.lastObject).pixelWidth;
            NSUInteger height = ((PHAsset *)fetchResult.lastObject).pixelHeight;
            
            CGSize targetSize = CGSizeMake(160,160*height/width);
            
            WS
            [imageManager requestImageForAsset:(PHAsset *)fetchResult.lastObject targetSize:targetSize contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                SS
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.posterView.image = result;
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageNamed:@"defaultcover"];
                self.posterView.image = image;
            });
        }
        
        NSString *albumName = [NSString stringWithFormat:@"%@  (%ld)",[((PHAssetCollection *)model) localizedTitle],(unsigned long)fetchResult.count];
        
        NSString *string = [((PHAssetCollection *)model) localizedTitle];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:albumName];
        [attributedString addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x979797) range:NSMakeRange(string.length, albumName.length - string.length)];
        WS
        dispatch_async(dispatch_get_main_queue(), ^{
            SS
            [self.albumNameView setAttributedText:attributedString];
        });
    }
}

@end
