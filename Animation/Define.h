//
//  Define.m
//  Animation
//
//  Created by liyanjun on 2018/3/16.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RATIO (SCREEN_WIDTH / 375.0)
#define Ration(num) (num * RATIO)

/**
 *
 * screen size
 *
 */
#define SCREEN_BOUNDS ([UIScreen mainScreen].bounds)

/**
 *
 * screen width
 *
 */
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)


/**
 *
 * sceen height
 *
 */
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//16进制颜色
#define HEX_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0 alpha:1.0]
#define HEX_COLOR_ALPHA(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0 alpha:a]

#define WS  __weak __typeof(self)weakSelf = self;
#define SS  __strong __typeof(weakSelf) self = weakSelf;

#define LineColor [HEX_COLOR(0x979797) colorWithAlphaComponent:0.5]
#define kThemeColor HEX_COLOR_ALPHA(0x0bbe06, 1)
#define kThemeColorDisabled HEX_COLOR_ALPHA(0x0bbe06, 0.5)
#define kThemeColorHL HEX_COLOR_ALPHA(0x1AA81C, 1)


