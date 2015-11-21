//
//  UIView+Frame.m
//  Test
//
//  Created by 刘杨 on 15/9/15.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size{
    return self.frame.size;
}

- (CGPoint)origin{
    return self.frame.origin;
}


void ly_frame(UIView *view, CGFloat x, CGFloat y, CGFloat width, CGFloat height){
    view.x = x;
    view.y = y;
    view.width = width;
    view.height = height;
}

void ly_x(UIView *view, CGFloat x){
    view.x = x;
}
void ly_y(UIView *view, CGFloat y){
    view.y = y;
}

void ly_width(UIView *view, CGFloat width){
    view.width = width;
}
void ly_height(UIView *view, CGFloat height){
    view.height = height;
}

void ly_size(UIView *view, CGSize size){
    view.size = size;
}
void ly_origin(UIView *view, CGPoint origin){
    view.origin = origin;
}

void ly_centerX(UIView *view, CGFloat centerX){
    view.centerX = centerX;
}
void ly_centerY(UIView *view, CGFloat centerY){
    view.centerY = centerY;
}

@end
