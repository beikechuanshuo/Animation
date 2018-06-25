//
//  ImagePickerViewController.h
//  Animation
//
//  Created by liyanjun on 2018/4/16.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImagePickerViewController;

@protocol ImagePickerViewControllerDelegate <NSObject>

- (void)ImagePickerViewController:(ImagePickerViewController *)VC selectImage:(NSArray *)imageAssets;

@end

@interface ImagePickerViewController : UIViewController

@property (nonatomic, strong) id assets;

@property (nonatomic, weak) id<ImagePickerViewControllerDelegate>delegate;

@end
