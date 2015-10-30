//
//  do_ProgressBar1_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ProgressBar1_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doTextHelper.h"
#import "doIOHelper.h"
#import "doISourceFS.h"
#import "doIPage.h"

typedef NS_ENUM(NSInteger,BarStyle) {
    Normal = 0,
    Zoom = 1
};
@interface do_ProgressBar1_UIView()
/** The number of circle indicators. */
@property (assign, nonatomic) int numberOfCircles;

/** The spacing between circles. */
@property (assign, nonatomic) CGFloat internalSpacing;

/** The radius of each circle. */
@property (assign, nonatomic) CGFloat radius;

/** The base animation delay of each circle. */
@property (assign, nonatomic) CGFloat delay;

/** The base animation duration of each circle*/
@property (assign, nonatomic) CGFloat duration;

@property (assign, nonatomic) BOOL isAnimating;


@end

@implementation do_ProgressBar1_UIView
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
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    [self setupDefaults];
}
//销毁所有的全局对象
- (void) OnDispose
{
    [self stopAnimating];
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_changeImage:(NSString *)newValue
{
    //自己的代码实现
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:_model.CurrentPage.CurrentApp :newValue];
    _changeImage = [UIImage imageWithContentsOfFile:imgPath];
    if (self.numberOfCircles == 0) {
        return;
    }
    [self stopAnimating];
    [self startAnimating];
}
- (void)change_defaultImage:(NSString *)newValue
{
    //自己的代码实现
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:_model.CurrentPage.CurrentApp :newValue];
    _defaultImage = [UIImage imageWithContentsOfFile:imgPath];
    if (self.numberOfCircles == 0) {
        return;
    }
    [self stopAnimating];
    [self startAnimating];
}
- (void)change_pointColors:(NSString *)newValue
{
    //自己的代码实现
    NSArray *array  = [newValue componentsSeparatedByString:@","];
    _pointColors = [self getColorsFromArray:array];
    if (self.numberOfCircles == 0) {
        return;
    }
    [self stopAnimating];
    [self startAnimating];
}
- (void)change_pointNum:(NSString *)newValue
{
    //自己的代码实现
    self.numberOfCircles = [[doTextHelper Instance]StrToInt:newValue :0];
    [self stopAnimating];
    [self startAnimating];
}
- (void)change_style:(NSString *)newValue
{
    //自己的代码实现
    if ([newValue isEqualToString:@"zoom"]) {
        _style = Zoom;
    }
    else if([newValue isEqualToString:@"normal"])
    {
        _style = Normal;
    }
}
#pragma -mark - 私有方法
- (void)setupDefaults
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberOfCircles = 0;
    self.internalSpacing = 1;
    self.radius = (MIN(_model.RealWidth, _model.RealHeight)) / 2;
    self.delay = 0.2;
    self.duration = 0.8;
}
- (void)startAnimating
{
    if (!self.isAnimating)
    {
        if (_style == Zoom) {
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
        NSLog(@"x==%f",x);
        UIImageView *circle = [self createCircleWithRadius:self.radius positionX:x];
        circle.image = _defaultImage;
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
    NSLog(@"_currentX%f",_currentX);
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
    if (index < _pointColors.count) {
        return [_pointColors objectAtIndex:index];
    }
    else
    {
        return [_pointColors lastObject];
    }
}
//得到远点的x
- (CGFloat )getViewXFormIndex:(NSUInteger )index
{
    CGFloat supViewX = self.center.x;
    int half = self.numberOfCircles / 2;
    if (index < half) {
        if (self.numberOfCircles % 2 == 0) {
            return supViewX - ((half - index) * self.radius * 2 + index * self.internalSpacing);
        }
        else
        {
            return supViewX - ((half - index) * self.radius * 2 + self.radius + index * self.internalSpacing);
        }
    }
    else
    {
        if (self.numberOfCircles % 2 == 0) {
            return supViewX + ((index - half) * self.radius * 2 + index * self.internalSpacing);
        }
        else
        {
            return supViewX + ((index - half) * self.radius * 2 - self.radius + index * self.internalSpacing);
        }
    }
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

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
