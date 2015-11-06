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
#import "doCustomActivityView.h"

@implementation do_ProgressBar1_UIView
{
    doCustomActivityView *_activityView;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    self.clipsToBounds = YES;
    _activityView = [[doCustomActivityView alloc]init];
    _activityView.radius = (MIN(_model.RealWidth, _model.RealHeight)) / 2;
    _activityView.supWidth = _model.RealWidth;
    _activityView.center = self.center;
    [self addSubview:_activityView];
}
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    _activityView.center = CGPointMake(self.center.x, _model.RealHeight / 2);
    _activityView.supWidth = _model.RealWidth;
    CGFloat radius = (MIN(_model.RealWidth, _model.RealHeight)) / 2;
    if (radius != _activityView.radius) {
        _activityView.radius = radius;
        [_activityView onRedrawView];
        _activityView.center = CGPointMake(self.center.x, _model.RealHeight / 2);
    }
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
    _activityView.changeImage = [UIImage imageWithContentsOfFile:imgPath];
}
- (void)change_defaultImage:(NSString *)newValue
{
    //自己的代码实现
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:_model.CurrentPage.CurrentApp :newValue];
    _activityView.defauleImage = [UIImage imageWithContentsOfFile:imgPath];
}
- (void)change_pointColors:(NSString *)newValue
{
    //自己的代码实现
    NSArray *array  = [newValue componentsSeparatedByString:@","];
    _activityView.colors = array;
}
- (void)change_pointNum:(NSString *)newValue
{
    //自己的代码实现
    _activityView.numberOfCircles = [[doTextHelper Instance]StrToInt:newValue :0];
    _activityView.center = CGPointMake(self.center.x, _model.RealHeight / 2);
}
- (void)change_style:(NSString *)newValue
{
    //自己的代码实现
    if ([newValue isEqualToString:@"zoom"]) {
        _activityView.styleMode = @"zoom";
    }
    else if([newValue isEqualToString:@"normal"])
    {
        _activityView.styleMode = @"normal";
    }
    [_activityView startAnimating];
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
