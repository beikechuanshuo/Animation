//
//  HomePageViewController.m
//  Animation
//
//  Created by liyanjun on 2018/3/14.
//  Copyright © 2018年 liyanjun. All rights reserved.
//

#import "HomePageViewController.h"
#import "YYLabel.h"
#import "CALayer+Extension.h"
#import "YYCategories.h"
#import "YYText.h"
#import "Define.h"
#import "PhotoViewController.h"

//内敛函数
static inline CGFloat BirthDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}

static NSTimeInterval const kAnimationDuriation = 1.0f;
static NSString *const kAnimationIdentifier = @"birthdayAnimationIdentifier";
static NSString *const kAnimationTypeLib = @"libAnimation";
static NSString *const kAnimationTypeHeart1 = @"animationHeart1";
static NSString *const kAnimationTypeHeart2 = @"animationHeart2";
static NSString *const kAnimationTypeText = @"animationText";

@interface HomePageViewController ()<CAAnimationDelegate>

//礼品盒盖子
@property (nonatomic, strong) CALayer *boxLidLayer;

//礼品盒子
@property (nonatomic, strong) CALayer *boxBodyLayer;

/** 盒子前面  正视图 用于遮挡音符 有种从盒子里面跑出来的感觉 */
@property (nonatomic, strong) CALayer *frontLayer;

//爱心层
@property (nonatomic, strong) CALayer *heartLayer;

//爱心动画结束后的大小
@property (nonatomic, assign) CGRect heartBounds;

//花絮
@property (nonatomic, strong) CALayer *blindLayer;

//左侧音符
@property (nonatomic, strong) CALayer *leftNoteLayer;

//中间音符
@property (nonatomic, strong) CALayer *midNoteLayer;

//右侧音符
@property (nonatomic, strong) CALayer *rightNoteLayer;

/** 文字 */
@property (nonatomic, strong) YYLabel *textLabel;

//点击事件1
@property (nonatomic, strong) UITapGestureRecognizer *tap;

//点击事件2
@property (nonatomic, strong) UITapGestureRecognizer *textLabelTap;

@end

@implementation HomePageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionToStartAnimation:)];
    [self.view addGestureRecognizer:self.tap];
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
    //盒子主题
    self.boxBodyLayer.position = CGPointMake(self.view.width/2, self.view.height-100);
    [self.view.layer addSublayer:self.boxBodyLayer];
    
    //盒子盖子
    self.boxLidLayer.position = CGPointMake(self.view.width/2, self.boxBodyLayer.top+Ration(16.5));

    //爱心
    self.heartLayer.position = CGPointMake(self.view.width/2, self.boxBodyLayer.bottom-10);
    self.heartLayer.bounds = CGRectZero;
    [self.view.layer addSublayer:self.heartLayer];
    
    //花絮
    self.blindLayer.position = CGPointMake(self.view.width/2, self.boxBodyLayer.bottom);;
    [self.view.layer addSublayer:self.blindLayer];
    
    //音符
    CGPoint musicPosition = CGPointMake(self.view.width/2, self.boxLidLayer.bottom + self.leftNoteLayer.height/2);
    
    self.leftNoteLayer.position = musicPosition;
    [self.view.layer addSublayer:self.leftNoteLayer];
    
    self.rightNoteLayer.position = musicPosition;
    [self.view.layer addSublayer:self.rightNoteLayer];
    
    self.midNoteLayer.position = musicPosition;
    [self.view.layer addSublayer:self.midNoteLayer];
    
    //盒子前面
    self.frontLayer.position = CGPointMake(self.view.width/2, self.view.height-100);
    [self.view.layer addSublayer:self.frontLayer];
    
    [self.view.layer addSublayer:self.boxLidLayer];
    
    self.textLabel = [[YYLabel alloc] initWithFrame:CGRectMake(0, self.view.height/2-60, self.view.width, 60)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.hidden = YES;
    [self.view addSubview:self.textLabel];
    
    self.textLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextAction:)];
    [self.view addGestureRecognizer:self.textLabelTap];
}

- (CAShapeLayer *)drawTipsLayerWithWidth:(CGFloat)width height:(CGFloat)height
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
    [aPath moveToPoint:CGPointMake(0.0,height)];
    [aPath addLineToPoint:CGPointMake(0.0,height/2)];
    [aPath addArcWithCenter:CGPointMake(height/2, height/2) radius:height/2 startAngle:-M_PI endAngle:-M_PI_2 clockwise:YES];
    [aPath addLineToPoint:CGPointMake(width-height/2, 0)];
    [aPath addArcWithCenter:CGPointMake(width-height/2, height/2) radius:height/2 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
    [aPath addLineToPoint:CGPointMake(0.0, height)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.lineWidth = 1.0;
    maskLayer.lineCap = kCALineJoinRound;  // 线条拐角
    maskLayer.lineJoin = kCALineJoinRound;   //  终点处理
    maskLayer.strokeColor = [UIColor redColor].CGColor;
    maskLayer.path = aPath.CGPath;
    maskLayer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.8].CGColor;
    return maskLayer;
}

- (UIBezierPath *)drawHeartWithRect:(CGRect)rect
{
    NSInteger angle = M_PI*3/4;
    if (angle == M_PI*2/3)
    {
        //120度
        //边距
        CGFloat drawingPadding = 4.0;
        //❤️上面的圆的半径 宽度减去两边空隙除以3，即可画出三分之一圆；三角函数计算获得
        CGFloat curveRadius = floor((CGRectGetWidth(rect) - 2*drawingPadding) / 3.0);
        
        //创建路径
        UIBezierPath *heartPath = [UIBezierPath bezierPath];
        
        //以💖的底部顶点为基点 顺时针画：弧度-半圆-半圆-弧度连接基点
        //1.移动到💖的底部顶点
        CGPoint bottomLocation = CGPointMake(floor(CGRectGetWidth(rect) / 2.0), CGRectGetHeight(rect) - drawingPadding);
        [heartPath moveToPoint:bottomLocation];
        
        //2.画左边的弧形 贝赛尔曲线
        CGPoint endPintLeftCurve = CGPointMake(drawingPadding, floor(CGRectGetHeight(rect) / 2.4));
        [heartPath addQuadCurveToPoint:endPintLeftCurve controlPoint:CGPointMake(endPintLeftCurve.x, endPintLeftCurve.y + curveRadius)];
        
        //3.画左边的三分之一圆
        [heartPath addArcWithCenter:CGPointMake(endPintLeftCurve.x + curveRadius, endPintLeftCurve.y) radius:curveRadius startAngle:-M_PI endAngle:-M_PI/3 clockwise:YES];
        
        //4.画右边的三分之一圆
        CGPoint topRightCurveCenter = CGPointMake(endPintLeftCurve.x + 2*curveRadius, endPintLeftCurve.y);
        [heartPath addArcWithCenter:topRightCurveCenter radius:curveRadius startAngle:-M_PI*2/3 endAngle:0 clockwise:YES];

        //5.画右边的弧形 贝塞尔曲线
        CGPoint rightControlPoint = CGPointMake(endPintLeftCurve.x + 3*curveRadius, endPintLeftCurve.y + curveRadius);
        [heartPath addQuadCurveToPoint:bottomLocation controlPoint:rightControlPoint];

        return heartPath;
    }
    else
    {
        //135度
        //边距
        CGFloat drawingPadding = 4.0;
        //❤️上面的圆的半径 宽度减去两边空隙除以3，即可画出三分之一圆；三角函数计算获得
        CGFloat curveRadius = floor((CGRectGetWidth(rect) - 2*drawingPadding)/(2+sqrt(2)));
        
        //创建路径
        UIBezierPath *heartPath = [UIBezierPath bezierPath];
        
        //以💖的底部顶点为基点 顺时针画：弧度-半圆-半圆-弧度连接基点
        //1.移动到💖的底部顶点
        CGPoint bottomLocation = CGPointMake(floor(CGRectGetWidth(rect) / 2.0), CGRectGetHeight(rect) - drawingPadding);
        [heartPath moveToPoint:bottomLocation];
        
        //2.画左边的弧形 贝赛尔曲线
        CGPoint endPintLeftCurve = CGPointMake(drawingPadding, floor(CGRectGetHeight(rect) / 2.6));
        [heartPath addQuadCurveToPoint:endPintLeftCurve controlPoint:CGPointMake(endPintLeftCurve.x, endPintLeftCurve.y + curveRadius)];
        
        //3.画左边的三分之一圆
        [heartPath addArcWithCenter:CGPointMake(endPintLeftCurve.x + curveRadius, endPintLeftCurve.y) radius:curveRadius startAngle:-M_PI endAngle:-M_PI/4 clockwise:YES];
        
        //4.画右边的三分之一圆
        CGPoint topRightCurveCenter = CGPointMake(endPintLeftCurve.x + (1+sqrt(2))*curveRadius, endPintLeftCurve.y);
        [heartPath addArcWithCenter:topRightCurveCenter radius:curveRadius startAngle:-M_PI*3/4 endAngle:0 clockwise:YES];

        //5.画右边的弧形 贝塞尔曲线
        CGPoint rightControlPoint = CGPointMake(CGRectGetWidth(rect)-drawingPadding, endPintLeftCurve.y + curveRadius);
        [heartPath addQuadCurveToPoint:bottomLocation controlPoint:rightControlPoint];
    
        return heartPath;
    }
}

//传入短边的尺寸和大约中点
- (UIBezierPath *)drawHeartWithMinLength:(CGFloat)minLength center:(CGPoint)center
{
    NSInteger angle = M_PI*3/4;
    
    //只取最小边的尺寸当成需要绘制的尺寸
    if (angle == M_PI*2/3)
    {
        //120度
        CGFloat drawingPadding = 50.0;
        //❤️上面的圆的半径 宽度减去两边空隙除以3，即可画出三分之一圆；三角函数计算获得
        CGFloat curveRadius = floor((minLength - 2*drawingPadding) / 3.0);
        
        //创建路径
        UIBezierPath *heartPath = [UIBezierPath bezierPath];
        
        //以💖的底部顶点为基点 顺时针画：弧度-半圆-半圆-弧度连接基点
        //1.移动到💖的底部顶点
        CGPoint bottomLocation = CGPointMake(center.x,center.y+2.0*curveRadius);
        [heartPath moveToPoint:bottomLocation];
        
        //2.画左边的弧形 贝赛尔曲线
        CGPoint endPintLeftCurve = CGPointMake(drawingPadding, center.y);
        [heartPath addQuadCurveToPoint:endPintLeftCurve controlPoint:CGPointMake(endPintLeftCurve.x, endPintLeftCurve.y + curveRadius)];
        
        //3.画左边的三分之一圆
        [heartPath addArcWithCenter:CGPointMake(endPintLeftCurve.x + curveRadius, endPintLeftCurve.y) radius:curveRadius startAngle:-M_PI endAngle:-M_PI/3 clockwise:YES];
        
        //4.画右边的三分之一圆
        CGPoint topRightCurveCenter = CGPointMake(endPintLeftCurve.x + 2*curveRadius, endPintLeftCurve.y);
        [heartPath addArcWithCenter:topRightCurveCenter radius:curveRadius startAngle:-M_PI*2/3 endAngle:0 clockwise:YES];
        
        //5.画右边的弧形 贝塞尔曲线
        CGPoint rightControlPoint = CGPointMake(minLength-drawingPadding, endPintLeftCurve.y + curveRadius);
        [heartPath addQuadCurveToPoint:bottomLocation controlPoint:rightControlPoint];
        
        return heartPath;
    }
    else
    {
        //135度
        //边距
        CGFloat drawingPadding = 50.0;
        //❤️上面的圆的半径 宽度减去两边空隙除以3，即可画出三分之一圆；三角函数计算获得
        CGFloat curveRadius = floor((minLength - 2*drawingPadding)/(2+sqrt(2)));
        
        //创建路径
        UIBezierPath *heartPath = [UIBezierPath bezierPath];
        
        //以💖的底部顶点为基点 顺时针画：弧度-半圆-半圆-弧度连接基点
        //1.移动到💖的底部顶点
        CGPoint bottomLocation = CGPointMake(center.x,center.y+2.0*curveRadius);
        [heartPath moveToPoint:bottomLocation];
        
        //2.画左边的弧形 贝赛尔曲线
        CGPoint endPintLeftCurve = CGPointMake(drawingPadding, center.y);
        [heartPath addQuadCurveToPoint:endPintLeftCurve controlPoint:CGPointMake(endPintLeftCurve.x, endPintLeftCurve.y + curveRadius)];
        
        //3.画左边的三分之一圆
        [heartPath addArcWithCenter:CGPointMake(endPintLeftCurve.x + curveRadius, endPintLeftCurve.y) radius:curveRadius startAngle:-M_PI endAngle:-M_PI/4 clockwise:YES];
        
        //4.画右边的三分之一圆
        CGPoint topRightCurveCenter = CGPointMake(endPintLeftCurve.x + (1+sqrt(2))*curveRadius, endPintLeftCurve.y);
        [heartPath addArcWithCenter:topRightCurveCenter radius:curveRadius startAngle:-M_PI*3/4 endAngle:0 clockwise:YES];
        
        //5.画右边的弧形 贝塞尔曲线
        CGPoint rightControlPoint = CGPointMake(minLength-drawingPadding, endPintLeftCurve.y + curveRadius);
        [heartPath addQuadCurveToPoint:bottomLocation controlPoint:rightControlPoint];
        
        return heartPath;
    }
}


#pragma mark - 点击开始动画
- (void)tapActionToStartAnimation:(UITapGestureRecognizer *)tap
{
    //5秒以后 可以点击屏幕 隐藏礼物弹窗
    self.tap.enabled = NO;
    
    NSMutableArray *values = [NSMutableArray array];
    for (NSInteger i = 1; i < 60; i++)
    {
        [values addObject:@(BirthDegreesToRadians(-i))];
    }
    
    //路径 移动
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.path = [self pathThatBoxLidMoved].CGPath;
    
    
    //旋转
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = values;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[moveAnimation, rotationAnimation];
    group.delegate = self;
    group.duration = kAnimationDuriation;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //防止动画结束 回到原处
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    //标记
    [group setValue:kAnimationTypeLib forKey:kAnimationIdentifier];
    [self.boxLidLayer addAnimation:group forKey:kAnimationTypeLib];
}

//绘制盒子移动的路径
- (UIBezierPath *)pathThatBoxLidMoved
{
    CGFloat radius = _boxBodyLayer.height/2;
    CGFloat centerY = _boxBodyLayer.centerY;
    CGFloat centerX = _boxBodyLayer.centerX;
    // 盒子打开动画路径
    UIBezierPath *strokePath = [UIBezierPath bezierPath];
    for (NSInteger i = 1; i < 35; i++)
    {
        if (i < 30)
        {
            [strokePath addArcWithCenter:CGPointMake(centerX - i/2, centerY - i / 15.0) radius:radius
                              startAngle:BirthDegreesToRadians(-90-(i-1))
                                endAngle:BirthDegreesToRadians(-90-i) clockwise:NO];
        }
        else
        {
            [strokePath addArcWithCenter:CGPointMake(centerX - (0.5 * i), centerY - 2 + (i - 30) / 2.5)
                                  radius:radius
                              startAngle:BirthDegreesToRadians(-90-(i-1))
                                endAngle:BirthDegreesToRadians(-90-i) clockwise:NO];
        }
    }
    
    for (NSInteger i = 1; i < 17; i++) {
        [strokePath addArcWithCenter:CGPointMake(centerX - 17 + (i - 1 )/ 5.0, centerY + i / 4.0) radius:radius
                          startAngle:BirthDegreesToRadians(-124-(i-1))
                            endAngle:BirthDegreesToRadians(-124-i) clockwise:NO];
    }
    for (NSInteger i = 1; i < 5; i++) {
        [strokePath addArcWithCenter:CGPointMake(centerX - 14 - i / 8.0 , centerY + 4 + i / 2.0) radius:radius
                          startAngle:BirthDegreesToRadians(-140 + (i-1))
                            endAngle:BirthDegreesToRadians(-140 + i) clockwise:YES];
    }
    for (NSInteger i = 0; i < 6; i++) {
        [strokePath addArcWithCenter:CGPointMake(centerX - 15 - i, centerY + 6 + i)
                              radius:radius -  3
                          startAngle:BirthDegreesToRadians(-140-(i-1))
                            endAngle:BirthDegreesToRadians(-140-i) clockwise:NO];
    }
    
    return strokePath;
}

#pragma mark - 爱心的动画
- (void)showHeartWithAnimation
{
    //爱心
    self.heartLayer.bounds = self.heartBounds;
    CABasicAnimation *heartAnimtion = [self heartAnimation];
    [heartAnimtion setValue:kAnimationTypeHeart1 forKey:kAnimationIdentifier];
    heartAnimtion.delegate = self;
    [self.heartLayer addAnimation:heartAnimtion forKey:kAnimationTypeHeart1];
  
    
    //花絮
    self.blindLayer.bounds = self.heartBounds;
    CABasicAnimation *blindAnimation = [self heartAnimation];
    [self.blindLayer addAnimation:blindAnimation forKey:@"blindingAnimtation"];
}

- (CABasicAnimation *)heartAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = kAnimationDuriation;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    
    return animation;
}

#pragma mark - 显示音符动画
- (void)showMusicNoteWithAnimation
{
    CGFloat musicW = self.leftNoteLayer.width;
    CGFloat musicH = self.leftNoteLayer.height;
    CGPoint originPoint = CGPointMake(self.view.width/2, self.boxLidLayer.bottom + self.leftNoteLayer.height/2);
    CGPoint leftEndPoint = CGPointMake(Ration(40) + musicW/2, Ration(-70.0) + musicH/2);
    CGPoint midEndPoint = CGPointMake(Ration(168) + musicW/2, Ration(-120) + musicH/2);
    CGPoint rightEndPoint = CGPointMake(Ration(275) + musicW/2, Ration(-19) + musicH/2);
    
    //左边音符
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:originPoint];
    CGPoint leftControlPoint1 = CGPointMake(-10, self.view.height - 100);
    CGPoint leftControlPoint2 = CGPointMake(0, 0);
    [leftPath addCurveToPoint:leftEndPoint controlPoint1:leftControlPoint1 controlPoint2:leftControlPoint2];
    [self animationForBirthdayMusicAnimation:leftPath layer:self.leftNoteLayer];
    
    //中间音符
    UIBezierPath *middleOnePath = [UIBezierPath bezierPath];
    [middleOnePath moveToPoint:originPoint];
    CGPoint middleControlPoint1 = CGPointMake(self.view.width*3/2, -self.view.height/3);
    CGPoint middleControlPoint2 = CGPointMake(0, self.view.height/2);
    [middleOnePath addCurveToPoint:midEndPoint controlPoint1:middleControlPoint1 controlPoint2:middleControlPoint2];
    [self animationForBirthdayMusicAnimation:middleOnePath layer:self.midNoteLayer];
    
    //右边音符
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:originPoint];
    CGPoint rightControlPoint1 = CGPointMake(self.view.width, self.view.height/2);
    CGPoint rightControlPoint2 = CGPointMake(self.view.width*2/3, self.view.height/5);
    [rightPath addCurveToPoint:rightEndPoint controlPoint1:rightControlPoint1 controlPoint2:rightControlPoint2];
    [self animationForBirthdayMusicAnimation:rightPath layer:self.rightNoteLayer];
}

- (void)animationForBirthdayMusicAnimation:(UIBezierPath *)bezierPath layer:(CALayer *)layer
{
    // 音符位置变化
    CAKeyframeAnimation *musicAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    musicAnimation.path = bezierPath.CGPath;
    
    // 音符透明度变化
    CABasicAnimation *musicOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    musicOpacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    musicOpacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    musicOpacityAnimation.beginTime = 0.2;
    
    // 音符组动画
    CAAnimationGroup * musicGroupAnimation = [CAAnimationGroup animation];
    musicGroupAnimation.animations = @[musicAnimation,musicOpacityAnimation];
    musicGroupAnimation.duration = kAnimationDuriation * 3;
    musicGroupAnimation.removedOnCompletion = NO;
    musicGroupAnimation.repeatCount = MAXFLOAT;
    musicGroupAnimation.fillMode = kCAFillModeForwards;
    musicGroupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:musicGroupAnimation forKey:@"musicGroupAnimation"];
}

#pragma mark -爱心飘荡的动画
- (void)showAnimation2ForHeart
{
    CGPoint originPoint = self.heartLayer.position;
    CGPoint rightEndPoint = CGPointMake(Ration(225) + self.heartLayer.width/2, Ration(-109) + self.heartLayer.height/2);
    UIBezierPath *heartPath = [UIBezierPath bezierPath];
    [heartPath moveToPoint:originPoint];
    CGPoint rightControlPoint1 = CGPointMake(self.view.width, self.view.height/2);
    CGPoint rightControlPoint2 = CGPointMake(self.view.width*2/3, self.view.height/5);
    [heartPath addCurveToPoint:rightEndPoint controlPoint1:rightControlPoint1 controlPoint2:rightControlPoint2];

    // 爱心位置变化
    CAKeyframeAnimation *heartAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    heartAnimation.path = heartPath.CGPath;
    heartAnimation.fillMode = kCAFillModeForwards;
    heartAnimation.removedOnCompletion = NO;
    heartAnimation.delegate = self;
    heartAnimation.duration = kAnimationDuriation*3;
    [heartAnimation setValue:kAnimationTypeHeart2 forKey:kAnimationIdentifier];
    [self.heartLayer addAnimation:heartAnimation forKey:kAnimationTypeHeart2];
}

#pragma mark -
- (void)textAnimationWithText:(NSString *)text
{
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:text];
    one.yy_font = [UIFont fontWithName:@"Zapfino" size:26];
    one.yy_color = [UIColor whiteColor];
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = [UIColor colorWithWhite:0.000 alpha:0.490];
    shadow.offset = CGSizeMake(0, 1);
    shadow.radius = 5;
    one.yy_textShadow = shadow;
    
    self.textLabel.hidden = NO;
    self.textLabel.attributedText = one;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = kAnimationDuriation;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1.0];

    [animation setValue:kAnimationTypeText forKey:kAnimationIdentifier];
    [self.textLabel.layer addAnimation:animation forKey:kAnimationTypeText];
}

- (void)tapTextAction:(UITapGestureRecognizer *)tap
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:photoVC animated:YES];
}

#pragma mark - 动画完成的回调函数
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString *animationType = [anim valueForKey:kAnimationIdentifier];
    if ([animationType isEqualToString:kAnimationTypeLib])
    {
        //1.弹出爱心
        [self showHeartWithAnimation];
    
        //2.显示音符
        [self showMusicNoteWithAnimation];
    }
    else if ([animationType isEqualToString:kAnimationTypeHeart1])
    {
        [self showAnimation2ForHeart];
    }
    else if ([animationType isEqualToString:kAnimationTypeHeart2])
    {
        [self textAnimationWithText:@"点击有惊喜"];
    }
}

#pragma mark - 懒加载图层
- (CALayer *)boxLidLayer
{
    if (_boxLidLayer == nil)
    {
        _boxLidLayer = [CALayer layerWithImageName:@"boxlid"];
    }
    
    return _boxLidLayer;
}

- (CALayer *)boxBodyLayer
{
    if (_boxBodyLayer == nil)
    {
        _boxBodyLayer = [CALayer layerWithImageName:@"boxbody"];
    }
    return _boxBodyLayer;
}

- (CALayer *)frontLayer
{
    if (_frontLayer == nil)
    {
        _frontLayer = [CALayer layerWithImageName:@"boxbody_front"];
    }
    return _frontLayer;
}

- (CALayer *)heartLayer
{
    if (_heartLayer == nil)
    {
        _heartLayer = [CALayer layerWithImageName:@"heart"];
        _heartBounds = _heartLayer.bounds;
    }
    return _heartLayer;
}

- (CALayer *)blindLayer
{
    if (_blindLayer == nil)
    {
        _blindLayer = [CALayer layerWithImageName:@"blingbling"];
    }
    return _blindLayer;
}

- (CALayer *)leftNoteLayer
{
    if (_leftNoteLayer == nil)
    {
        _leftNoteLayer = [CALayer layerWithImageName:@"music"];
    }
    return _leftNoteLayer;
}

- (CALayer *)midNoteLayer
{
    if (_midNoteLayer == nil)
    {
        _midNoteLayer = [CALayer layerWithImageName:@"music"];
    }
    return _midNoteLayer;
}

- (CALayer *)rightNoteLayer
{
    if (_rightNoteLayer == nil)
    {
        _rightNoteLayer = [CALayer layerWithImageName:@"music"];
    }
    return _rightNoteLayer;
}


@end
