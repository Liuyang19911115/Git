//
//  UIView+Frame.h
//  Test
//
//  Created by 刘杨 on 15/9/15.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

//给定一个View的frame c 函数
void ly_frame(UIView *view, CGFloat x, CGFloat y, CGFloat width, CGFloat height);

void ly_x(UIView *view, CGFloat x);
void ly_y(UIView *view, CGFloat y);

void ly_width(UIView *view, CGFloat width);
void ly_height(UIView *view, CGFloat height);

void ly_size(UIView *view, CGSize size);
void ly_origin(UIView *view, CGPoint origin);

void ly_centerX(UIView *view, CGFloat centerX);
void ly_centerY(UIView *view, CGFloat centerY);


@end
