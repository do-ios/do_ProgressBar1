//
//  do_ProgressBar1_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_ProgressBar1_IView <NSObject>

@required
//属性方法
- (void)change_changeImage:(NSString *)newValue;
- (void)change_defaultImage:(NSString *)newValue;
- (void)change_pointColors:(NSString *)newValue;
- (void)change_pointNum:(NSString *)newValue;
- (void)change_style:(NSString *)newValue;

//同步或异步方法


@end