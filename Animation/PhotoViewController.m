//
//  PhotoViewController.m
//  Animation
//
//  Created by liyanjun on 2018/3/19.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import "PhotoViewController.h"
#import "AnimationCollectViewFlowLayout.h"
#import "Define.h"
#import "PhotoCollectionViewCell.h"
#import "UIView+YYAdd.h"
#import "YYText.h"
#import "ImagePickerViewController.h"

#define kNavHeight 64

@class PhotoModel;

static NSString *const kReuseCollectionCell = @"reuseCollectionCellIdentifier";

@interface PhotoViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,CAAnimationDelegate,ImagePickerViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *photoCollectionView;

@property (nonatomic, strong) NSArray *photoArray;

@property (nonatomic, strong) CAEmitterLayer *fireLayer;

@property (nonatomic, strong) UILabel *imagePickerLabel;

@property (nonatomic, assign) BOOL animationFinish;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.photoArray = [self getPhotoArrayForTest];
    [self setupUI];
    
    NSError *error = nil;
    [NSString stringWithFormat:@"%@",error.description];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupUI
{
    [self.view addSubview:self.photoCollectionView];
    
    [self.view addSubview:self.imagePickerLabel];
    
    self.fireLayer = [CAEmitterLayer layer];
    [self fireConfiguration];
    [self.view.layer addSublayer:self.fireLayer];
    
    self.animationFinish = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInputImageAction:)];
    [self.view addGestureRecognizer:tap];
}

- (NSArray *)getPhotoArrayForTest
{
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < 2; i ++)
    {
        PhotoModel *model = [[PhotoModel alloc] init];
        NSString *imageName = [NSString stringWithFormat:@"photo_%02ld.jpeg",(random()%2+1)];
        model.photoName = imageName;
        model.index = i;
        [temp addObject:model];
    }
    
    return temp;
}

- (UICollectionView *)photoCollectionView
{
    if (_photoCollectionView == nil)
    {
        AnimationCollectViewFlowLayout *layout = [[AnimationCollectViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _photoCollectionView.pagingEnabled = YES;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        _photoCollectionView.showsHorizontalScrollIndicator = NO;
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        [_photoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:kReuseCollectionCell];
    }
    
    return _photoCollectionView;
}

- (UILabel *)imagePickerLabel
{
    if (_imagePickerLabel == nil)
    {
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:@"导入图片"];
        one.yy_font = [UIFont fontWithName:@"Zapfino" size:26];
        one.yy_color = [UIColor colorWithRed:0x0b/255.0 green:0xbe/255.0 blue:0x06/255.0 alpha:0.6];
        YYTextShadow *shadow = [YYTextShadow new];
        shadow.color = [UIColor colorWithWhite:0.000 alpha:0.490];
        shadow.offset = CGSizeMake(0, 1);
        shadow.radius = 5;
        one.yy_textShadow = shadow;
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        _imagePickerLabel = [[UILabel alloc] initWithFrame:CGRectMake((size.width-120)/2, size.height-40, 120, 40)];
        _imagePickerLabel.backgroundColor = [UIColor clearColor];
        _imagePickerLabel.attributedText = one;
        _imagePickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _imagePickerLabel;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseCollectionCell forIndexPath:indexPath];
    
    cell.model = self.photoArray[indexPath.row];
    cell.tag = indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.imagePickerLabel.layer removeAllAnimations];
    if (indexPath.row == self.photoArray.count-1)
    {
        //最后一页的时候，可以显示一个导入照片的按钮；
        self.imagePickerLabel.hidden = NO;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:0];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        [animation setValue:@"kAnimationTypeText" forKey:@"kAnimationIdentifier"];
        [self.imagePickerLabel.layer addAnimation:animation forKey:@"kAnimationTypeText"];
    }
    else if(indexPath.row == self.photoArray.count-2)
    {
        self.imagePickerLabel.hidden = NO;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [animation setValue:@"kAnimationTypeText" forKey:@"kAnimationIdentifier"];
        [self.imagePickerLabel.layer addAnimation:animation forKey:@"kAnimationTypeText"];

        self.animationFinish = NO;
    }
    else
    {
        self.animationFinish = NO;
        self.imagePickerLabel.hidden = YES;
    }
}

#pragma mark -
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
     NSString *animationType = [anim valueForKey:@"kAnimationIdentifier"];
    if ([animationType isEqualToString:@"kAnimationTypeText"])
    {
        self.imagePickerLabel.hidden = NO;
        self.animationFinish = YES;
    }
}

#pragma mark -点击导入图片
- (void)tapInputImageAction:(UITapGestureRecognizer *)tap
{
    if (self.animationFinish == NO)
    {
        return;
    }
    
    ImagePickerViewController *imagePickerVC = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    imagePickerVC.delegate = self;
    [self presentViewController:imagePickerVC animated:YES completion:^{
        
    }];
}


- (void)fireConfiguration
{
    self.fireLayer.emitterPosition = CGPointMake(self.view.width/2.0, self.view.height);
    self.fireLayer.emitterSize = CGSizeMake(2, 2);
    self.fireLayer.emitterMode = kCAEmitterLayerOutline;
    self.fireLayer.emitterShape = kCAEmitterLayerLine;
    self.fireLayer.renderMode = kCAEmitterLayerAdditive;
    self.fireLayer.seed = (arc4random()%100)+1;
    
    //rocket
    CAEmitterCell *rocket = [CAEmitterCell emitterCell];
    rocket.birthRate = 6.0;
    rocket.emissionRange = 0.12 * M_PI;
    rocket.velocity = 300;
    rocket.velocityRange = 150;
    rocket.yAcceleration = 0;
    rocket.lifetime = 2.02;
    
    rocket.contents = (id)[UIImage imageNamed:@"ball"].CGImage;
    rocket.scale = 0.2;
    rocket.greenRange = 1.0;
    rocket.redRange = 1.0;
    rocket.blueRange = 1.0;
    rocket.spinRange = M_PI;
    
    //burst
    CAEmitterCell *burst = [CAEmitterCell emitterCell];
    burst.birthRate = 1.0;
    burst.velocity = 0;
    burst.scale = 2.5;
    burst.redSpeed = -1.5;
    burst.blueSpeed = 1.5;
    burst.greenSpeed = 1.0;
    burst.lifetime = 0.35;
    
    //spark
    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.birthRate = 666;
    spark.velocity = 125;
    spark.emissionRange = 2 * M_PI;
    spark.yAcceleration = 75;
    spark.lifetime = 3;
    
    spark.contents= (id)[UIImage imageNamed:@"fire"].CGImage;
    spark.scale = 0.5;
    spark.scaleSpeed = -0.2;
    spark.greenSpeed = -0.1;
    spark.redSpeed = 0.4;
    spark.blueSpeed = -0.1;
    spark.alphaSpeed = -0.5;
    spark.spin = 2 * M_PI;
    spark.spinRange = 2 * M_PI;
    
    //together
    self.fireLayer.emitterCells = @[rocket];
    rocket.emitterCells = @[burst];
    burst.emitterCells = @[spark];
}

#pragma mark -ImagePickerViewControllerDelegate
- (void)ImagePickerViewController:(ImagePickerViewController *)VC selectImage:(NSArray *)imageAssets
{
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < imageAssets.count; i ++)
    {
        id asset = [imageAssets objectAtIndex:i];
        
        PhotoModel *model = [[PhotoModel alloc] init];
        NSString *imageName = nil;
        model.photoName = imageName;
        model.asset = asset;
        model.index = i;
        [temp addObject:model];
    }
    
    self.photoArray = temp;
    [self.photoCollectionView reloadData];
}


@end
