//
//  ImagePickerViewController.m
//  Animation
//
//  Created by liyanjun on 2018/4/16.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <Photos/Photos.h>
#import "Define.h"
#import "QIYIImageAlbumsView.h"
#import "HDevice.h"
#import "QIYIImagePickerCollectionViewCell.h"

//一行几个
#define PhotoLineCount 4

// 行间距
#define LineSpacing 5

// 列间距
#define ItemSpacing 5

#define OKBtnWidth 60

#define BackBtn_CancelBtn_Width 60

static NSString *QIYIImagePickerCollectionViewCellReuserIdentifier = @"QIYIImagePickerCollectionViewCellReuserIdentifier";

@interface ImagePickerViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QIYIImageAlbumsViewDelegate,QIYIImagePickerCollectionViewCellDelegate,QIYIImagePickerCollectionViewCellDelegate>

//底部控件
@property (nonatomic, strong) UIView *bottomView;

//顶部控件
@property (nonatomic, strong) UIView *topView;

//title
@property (nonatomic, strong) UILabel *titleView;

//发送按钮
@property (nonatomic, strong) UIButton *OKBtn;

//返回按钮
@property (nonatomic, strong) UIButton *backBtn;

//取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;

//显示选中数目控件
@property (nonatomic, strong) UILabel *selectedView;

//图片显示
@property (nonatomic, strong) UICollectionView *photoCollectionView;

//相册选择
@property (nonatomic, strong) QIYIImageAlbumsView *albumsView;

//相册
@property (nonatomic, strong) NSMutableArray *photosDataSource;

@property (nonatomic, assign) CGFloat cellWidth;

//相册数组
@property (nonatomic, strong) NSMutableArray *albumsArray;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //相册权限问题
    if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有相册权限啊！亲" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"哎呀 好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSURL * url = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
                [alert addAction:alertAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            }
        }];
    }
    else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有相册权限啊！亲" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"哎呀 好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alert addAction:alertAction];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
    [self setupUI];
    [self initOther];
    
    //获取cell宽度
    [self getCellWidth];
    
    //获取显示数据
    [self loadCameraRollAndUpdateUI];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)setupUI
{
    CGFloat navHeight = 64;
    CGFloat toolBarHeight = 49;
    if ([HDevice shareInstance].localizedModel == HDeviceLocalizedModel_iPhoneX)
    {
        navHeight = 88;
        toolBarHeight = 83;
    }

    //顶部控件
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), navHeight)];
    self.topView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.topView];
    
    //顶部控件细线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame)-0.5, CGRectGetWidth(self.topView.frame), 0.5)];
    topLine.backgroundColor = LineColor;
    [self.topView addSubview:topLine];
    
    //取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(CGRectGetMaxX(self.topView.frame)-BackBtn_CancelBtn_Width, navHeight - 44, BackBtn_CancelBtn_Width,44);
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.topView addSubview:self.cancelBtn];
    
    //title
    self.titleView = [[UILabel alloc] initWithFrame:CGRectMake(10+BackBtn_CancelBtn_Width, navHeight - 44, CGRectGetWidth(self.topView.frame)-BackBtn_CancelBtn_Width*2,44)];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.font = [UIFont boldSystemFontOfSize:18];
    self.titleView.textColor = [UIColor blackColor];
    [self.topView addSubview:self.titleView];
    
    //相册按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(5, navHeight - 44, BackBtn_CancelBtn_Width,44);
    self.backBtn.backgroundColor = [UIColor clearColor];
    [self.backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.backBtn setTitle: @"相册" forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(albumLibAction:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.topView addSubview:self.backBtn];
    
    //底部控件
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-toolBarHeight + 5, CGRectGetWidth(self.view.frame),toolBarHeight - 5)];
    self.bottomView.backgroundColor = HEX_COLOR(0xF6F6F6);
    [self.view addSubview:self.bottomView];
    
    //底部控件细线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bottomView.frame), 0.5)];
    bottomLine.backgroundColor = LineColor;
    [self.bottomView addSubview:bottomLine];
    
    //确定按钮
    self.OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.OKBtn.frame = CGRectMake(CGRectGetMaxX(self.bottomView.frame)-OKBtnWidth, 0, OKBtnWidth, 44);
    self.OKBtn.backgroundColor = [UIColor clearColor];
    self.OKBtn.enabled = NO;
    self.OKBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.OKBtn setTitle:@"OK" forState:UIControlStateNormal];
    [self.OKBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
    [self.OKBtn setTitleColor:kThemeColorDisabled forState:UIControlStateDisabled];
    [self.OKBtn addTarget:self action:@selector(OKAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.OKBtn];
    
    //显示选中数目控件
    self.selectedView = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetMinX(self.OKBtn.frame)-22), 11, 22, 22)];
    self.selectedView.layer.masksToBounds = YES;
    self.selectedView.layer.cornerRadius = 11;
    self.selectedView.backgroundColor = kThemeColor;
    self.selectedView.font = [UIFont systemFontOfSize:12];
    self.selectedView.text = [NSString stringWithFormat:@"%ld",(long)[[QIYIImagePickerManager sharedInstance] selectedPhotosCount]];
    self.selectedView.hidden = YES;
    self.selectedView.textAlignment = NSTextAlignmentCenter;
    self.selectedView.textColor = [UIColor whiteColor];
    [self.bottomView addSubview:self.selectedView];
    
    //collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, navHeight+LineSpacing, CGRectGetWidth(self.view.frame), (CGRectGetMinY(self.bottomView.frame) - CGRectGetMaxY(self.topView.frame) - 2*LineSpacing)) collectionViewLayout:flowLayout];
    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    [self.photoCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.photoCollectionView];
    
    [self.photoCollectionView registerClass:[QIYIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:QIYIImagePickerCollectionViewCellReuserIdentifier];
    
    //相册控件
    self.albumsView = [[QIYIImageAlbumsView alloc] initWithFrame:CGRectMake(-CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.albumsView.backgroundColor = [UIColor whiteColor];
    self.albumsView.delegate = self;
    [self.view addSubview:self.albumsView];
}

- (void)initOther
{
    self.photosDataSource = [[NSMutableArray alloc] init];
    self.albumsArray = [[NSMutableArray alloc] init];
    
    [[QIYIImagePickerManager sharedInstance] removeAllSelectedPhtots];
}

- (void)loadCameraRollAndUpdateUI
{
    //清空数据
    [self.photosDataSource removeAllObjects];
    WS
    [self loadAssetsFromLibrarySuccessBlock:^(NSArray *assetsArray) {
        SS
        id cameraRoll = nil;
        id allPhotos = nil;
    
        //获取相册数组
        for (id assets in assetsArray)
        {
            if([assets isKindOfClass:[PHAssetCollection class]])
            {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assets options:nil];
                
                if(fetchResult.count > 0)
                {
                    [self.albumsArray addObject:assets];
                }
                
                NSString *assetName = [((PHAssetCollection *)assets) localizedTitle];
                NSLog(@"%@",assetName);
                
                if (((PHAssetCollection *)assets).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
                {
                    cameraRoll = assets;
                    self.titleView.text = assetName;
                    break;
                }
            }
        }
        
        //如果没有照片胶卷相册，则读取所有相册里的照片
        if (cameraRoll == nil && allPhotos)
        {
            cameraRoll = allPhotos;
        }
        
        //加载胶卷相册，并且更新UI
        WS
        [self loadAssetsGroup:cameraRoll andUpdateUI:^(NSString *albumName,NSError *error){
            SS
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.photoCollectionView reloadData];
                if (self.photosDataSource && self.photosDataSource.count > 0)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.photosDataSource.count-1)  inSection:0];
                    [self.photoCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                    self.titleView.text = albumName;
                }
                else
                {
                    self.titleView.text = @"";
                }
                
            });
        }];
        
    } failBlock:^(NSError *error) {
        
    }];
}

//获取相册数据并更新UI
- (void)loadAssetsGroup:(id)assetsGroup andUpdateUI:(void(^)(NSString *albumName,NSError *error))updateUI
{
    self.assets = assetsGroup;
    [self.photosDataSource removeAllObjects];
    
    //获取相册名称
    NSString *albumName = nil;
    if([self.assets isKindOfClass:[PHAssetCollection class]])
    {
        albumName = [((PHAssetCollection *)self.assets) localizedTitle];
    }
    
    WS
    [self loadImageWithAssets:self.assets successBlock:^(NSArray *assets) {
        SS
        NSMutableArray *models = [NSMutableArray new];
        for (id asset in assets)
        {
            QIYIImagePickerCollectionViewCellModel *model = [QIYIImagePickerCollectionViewCellModel new];
            model.asset = asset;
            model.status = QIYIImagePickerCollectionViewCellSelectStatus_Normal;

            //判断是否选中
            BOOL ret = [[QIYIImagePickerManager sharedInstance] isSelectedPhotos:asset];
            if (ret)
            {
                model.status = QIYIImagePickerCollectionViewCellSelectStatus_Selected;
            }
            [models addObject:model];
        }
        
        self.photosDataSource = models;
        updateUI(albumName,nil);
    } failBlock:^(NSError *err) {
        updateUI(albumName,err);
    }];
}

//获取具体某个相册的照片
- (void)loadImageWithAssets:(id)assets successBlock:(void(^)(NSArray *))successBlock failBlock:(void(^)(NSError *))failBlock
{
    if (assets == nil)
    {
        NSError *error = [NSError errorWithDomain:@"参数错误" code:-1 userInfo:nil];
        failBlock(error);
        return;
    }
    
    __block NSMutableArray *images = [[NSMutableArray alloc] init];
    if ([assets isKindOfClass:[PHAssetCollection class]])
    {
        // 从一个相册中获取的PHFetchResult中包含的才是PHAsset
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assets options:nil];
        if (fetchResult.count != 0)
        {
            for (PHAsset *asset in fetchResult)
            {
                if (asset.mediaType == PHAssetMediaTypeImage)
                {
                     [images addObject:asset];
                }
            }
            
            successBlock(images);
        }
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"参数错误" code:-1 userInfo:nil];
        failBlock(error);
        NSLog(@"参数错误");
    }
}

//获取相册信息
- (void)loadAssetsFromLibrarySuccessBlock:(void(^)(NSArray *))successBlock failBlock:(void(^)(NSError *))failBlock
{
    __block NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    //我的照片流
    PHFetchResult *myPhotoStreamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    for (NSInteger i = 0; i< myPhotoStreamAlbums.count; i++)
    {
        // 获取一个相册PHAssetCollection
        PHCollection *collection = myPhotoStreamAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (((PHAssetCollection *)assetCollection).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
            {
                [assets insertObject:assetCollection atIndex:0];
            }
            else
            {
                [assets addObject:assetCollection];
            }
        }
        else
        {
            NSLog(@"%@",collection);
        }
    }
    
    //系统定义相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (NSInteger i = 0; i< smartAlbums.count; i++)
    {
        // 获取一个相册PHAssetCollection
        PHCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (((PHAssetCollection *)assetCollection).assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
            {
                [assets insertObject:assetCollection atIndex:0];
            }
            else
            {
                [assets addObject:assetCollection];
            }
        }
        else
        {
            NSLog(@"%@",collection);
        }
    }
    
    //自定义相册
    PHFetchResult *customAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (NSInteger i = 0; i< customAlbums.count; i++)
    {
        // 获取一个相册PHAssetCollection
        PHCollection *collection = customAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            [assets addObject:assetCollection];
        }
        else
        {
            NSLog(@"%@",collection);
        }
    }
    
    if(assets.count > 0)
    {
        successBlock(assets);
    }
    else
    {
        failBlock(nil);
    }
}




- (void)getCellWidth
{
    self.cellWidth = (CGFloat)([UIScreen mainScreen].bounds.size.width - (PhotoLineCount + 1) * ItemSpacing) / PhotoLineCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action -
- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
       
        [[QIYIImagePickerManager sharedInstance] removeAllSelectedPhtots];
        
    }];
}

- (void)albumLibAction:(id)sender
{
    self.albumsView.albumsArray = self.albumsArray;
    WS
    [[QIYIImagePickerManager sharedInstance] animationPushWithView:self.albumsView pushAnimationOrientation:PushAnimationOrientation_Left finishBlock:^{
        SS
        self.albumsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [self.view bringSubviewToFront:self.albumsView];
    }];
}

- (void)OKAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ImagePickerViewController:selectImage:)])
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[[QIYIImagePickerManager sharedInstance] getSelectedPhotos]];
        [self.delegate ImagePickerViewController:self selectImage:array];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[QIYIImagePickerManager sharedInstance] removeAllSelectedPhtots];
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, self.cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, LineSpacing, 0, LineSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return LineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return ItemSpacing;
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosDataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QIYIImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QIYIImagePickerCollectionViewCellReuserIdentifier forIndexPath:indexPath];
    
    if (indexPath.row < self.photosDataSource.count)
    {
        cell.model = self.photosDataSource[indexPath.row];
    }

    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - QIYIImagePickerCollectionViewCellDelegate -
- (void)cell:(QIYIImagePickerCollectionViewCell *)cell tapedView:(UIView *)view
{
    
}

- (void)cell:(QIYIImagePickerCollectionViewCell *)cell tapedSelectView:(UIView *)view
{
    if ([[QIYIImagePickerManager sharedInstance] selectedPhotosCount] > 0)
    {
        self.OKBtn.enabled = YES;
        self.selectedView.hidden = NO;
        WS
        [[QIYIImagePickerManager sharedInstance] animation1WithView:self.selectedView finishBlock:^{
            SS
            self.selectedView.text = [NSString stringWithFormat:@"%ld",(long)[[QIYIImagePickerManager sharedInstance] selectedPhotosCount]];
        }];
    }
    else
    {
        self.OKBtn.enabled = NO;
        WS
        [[QIYIImagePickerManager sharedInstance] animation1WithView:self.selectedView finishBlock:^{
            SS
            self.selectedView.text = [NSString stringWithFormat:@"%ld",(long)[[QIYIImagePickerManager sharedInstance] selectedPhotosCount]];
            self.selectedView.hidden = YES;
        }];
    }
}

- (void)imageAlbumsView:(QIYIImageAlbumsView *)view tapedCancelButton:(id)sender
{
    [self cancelAction:sender];
}

- (void)imageAlbumsView:(QIYIImageAlbumsView *)view selectedIndexPath:(NSIndexPath *)indexPath
{
    WS
    [self loadAssetsGroup:[self.albumsArray objectAtIndex:indexPath.row] andUpdateUI:^(NSString *albumName, NSError *error) {
        SS
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoCollectionView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.photosDataSource.count-1)  inSection:0];
            [self.photoCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            self.titleView.text = albumName;
            
            [[QIYIImagePickerManager sharedInstance] animationPushWithView:self.albumsView pushAnimationOrientation:PushAnimationOrientation_Right finishBlock:^{
                self.albumsView.frame = CGRectMake(-CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            }];
        });
    }];
}

@end
