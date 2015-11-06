//
//  doCustomActivityView.m
//  Do_Test
//
//  Created by yz on 15/11/2.
//  Copyright © 2015年 DoExt. All rights reserved.
//

#import "doCustomActivityView.h"
#import "doUIModuleHelper.h"

typedef NS_ENUM(NSInteger,BarStyle) {
    Normal = 0,
    Zoom = 1
};

@implementation doCustomActivityView
{
    BarStyle _style;
    NSArray *_pointColors;
    UIImage *_defaultImage;
    UIImage *_changeImage;
    UIImageView *_firstImageView;
    NSTimer *_timer;
    CGFloat _defaultX;
    CGFloat _currentX;
    CGFloat _endX;
    
    NSMutableArray *_circles;
}
- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

#pragma -mark - 私有方法
- (void)onRedrawView
{
    if (_numberOfCircles * self.radius * 2 > self.supWidth) {
        _numberOfCircles =  self.supWidth / (self.radius*2);
    }
    [self adjustFrame];
    [self stopAnimating];
    [self startAnimating];
}
- (void)setupDefaults
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.internalSpacing = 1;
    self.radius = 10;
    self.delay = 0.2;
    self.duration = 0.8;
    self.clipsToBounds = YES;
    _circles = [NSMutableArray array];
}
- (void)startAnimating
{
    if (!self.isAnimating)
    {
        if ([self.styleMode isEqualToString:@"zoom"]) {
            [self addCircles];
            self.hidden = NO;
            self.isAnimating = YES;
        }
        else
        {
            [self addImageView];
            self.hidden = NO;
            self.isAnimating = YES;
        }
    }
}
- (void)addImageView
{
    for (NSUInteger i = 0; i < self.numberOfCircles; i++)
    {
        CGFloat x = [self getViewXFormIndex:i];
        UIImageView *circle = [self createCircleWithRadius:self.radius positionX:x];
        circle.image = self.defauleImage;
        circle.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:circle];
        if (i == 0) {
            UIImageView *firstImage = [self createCircleWithRadius:self.radius positionX:x];
            _defaultX = firstImage.frame.origin.x;
            _currentX = _defaultX;
            firstImage.image = _changeImage;
            _firstImageView = firstImage;
            [self addSubview:firstImage];
        }
    }
    [self startTimer];
}
- (void) startTimer
{
    [self bringSubviewToFront:_firstImageView];
    _endX = _defaultX + (self.numberOfCircles) * self.radius * 2 + (self.numberOfCircles - 1) * self.internalSpacing;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeImageViewX) userInfo:nil repeats:YES];
}
- (void) stopTimer
{
    [_timer invalidate];
    _timer = nil;
}
- (void)changeImageViewX
{
    _currentX += (self.radius * 2) + self.internalSpacing;
    if (_currentX >= _endX) {
        _currentX = _defaultX;
    }
    _firstImageView.frame = CGRectMake(_currentX, _firstImageView.frame.origin.y, _firstImageView.frame.size.width, _firstImageView.frame.size.height);
}
- (UIImageView *)createCircleWithRadius:(CGFloat)radius positionX:(CGFloat)x
{
    UIImageView *circle = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, radius * 2, radius * 2)];
    circle.layer.cornerRadius = radius;
    circle.translatesAutoresizingMaskIntoConstraints = NO;
    return circle;
}


- (void)addCircles
{
    for (NSUInteger i = 0; i < self.numberOfCircles; i++)
    {
        UIColor *color = [self getColorFromIndex:i];
        CGFloat x = [self getViewXFormIndex:i];
        UIView *circle = [self createCircleWithRadius:self.radius
                                                color:color
                                            positionX:x];
        [circle setTransform:CGAffineTransformMakeScale(0, 0)];
        [circle.layer addAnimation:[self createAnimationWithDuration:self.duration delay:(i * self.delay)] forKey:@"scale"];
        [_circles addObject:circle];
        [self addSubview:circle];
    }
}
//得到颜色数组
- (NSArray *)getColorsFromArray:(NSArray *)array
{
    NSMutableArray *colors = [NSMutableArray array];
    for (NSString *colorStr in array) {
        UIColor *color = [doUIModuleHelper GetColorFromString:colorStr :[UIColor clearColor]];
        [colors addObject:color];
    }
    return colors;
}
//得到颜色
- (UIColor *)getColorFromIndex:(NSUInteger)index
{
    if (index >= _pointColors.count) {
        index = index % _pointColors.count;
    }
    return [_pointColors objectAtIndex:index];
}
//得到远点的x
- (CGFloat )getViewXFormIndex:(NSUInteger )index
{
    return index * ((2 * self.radius) + self.internalSpacing);
}
//创建远点view
- (UIView *)createCircleWithRadius:(CGFloat)radius
                             color:(UIColor *)color
                         positionX:(CGFloat)x
{
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(x, 0, radius * 2, radius * 2)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.translatesAutoresizingMaskIntoConstraints = NO;
    return circle;
}
//添加动画
- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.delegate = self;
    anim.fromValue = [NSNumber numberWithFloat:0.3f];
    anim.toValue = [NSNumber numberWithFloat:0.8f];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}
//结束动画
- (void)stopAnimating
{
    if (self.isAnimating)
    {
        self.hidden = YES;
        self.isAnimating = NO;
        [self removeCircles];
        if (_style == Normal)
        {
            [self stopTimer];
        }
    }
}
//移除添加的view
- (void)removeCircles
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void)adjustFrame
{
    CGRect frame = self.frame;
    frame.size.width = (self.numberOfCircles * ((2 * self.radius) + self.internalSpacing)) - self.internalSpacing;
    frame.size.height = self.radius * 2;
    self.frame = frame;
}
- (void)setNumberOfCircles:(int)numberOfCircles
{
    _numberOfCircles = numberOfCircles;
    if (numberOfCircles * self.radius * 2 > self.supWidth) {
        _numberOfCircles =  self.supWidth / (self.radius*2);
    }
    [self adjustFrame];
    [self stopAnimating];
    [self startAnimating];

}

- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    _pointColors = [self getColorsFromArray:colors];
    [self stopAnimating];
    [self startAnimating];
}
- (void)setStyleMode:(NSString *)styleMode
{
    _styleMode = styleMode;
    [self stopAnimating];
    [self startAnimating];
}
- (void)setDefauleImage:(UIImage *)defauleImage
{
    if ([self.styleMode isEqualToString:@"zoom"]) {
        return;
    }
    _defauleImage = defauleImage;
    [self stopAnimating];
    [self startAnimating];
}
- (void)setChangeImage:(UIImage *)changeImage
{
    if ([self.styleMode isEqualToString:@"zoom"]) {
        return;
    }
    _changeImage = changeImage;
    [self stopAnimating];
    [self startAnimating];
}
@end
