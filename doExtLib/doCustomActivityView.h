//
//  doCustomActivityView.h
//  Do_Test
//
//  Created by yz on 15/11/2.
//  Copyright © 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface doCustomActivityView : UIView
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

@property (assign, nonatomic) CGFloat supWidth;

@property (nonatomic, strong) UIImage *defauleImage;

@property (nonatomic, strong) UIImage *changeImage;

@property (nonatomic, strong)  NSArray *colors;

@property (nonatomic, strong)  NSString *styleMode;

- (void)startAnimating;
- (void)stopAnimating;

- (void)onRedrawView;
@end
