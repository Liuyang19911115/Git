//
//  LYToastView.h
//  VoiceBtn_test
//
//  Created by 刘杨 on 15/11/13.
//  Copyright © 2015年 刘杨. All rights reserved.
//
#define K_TEST 1             //测试用的宏

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#import <AVFoundation/AVFoundation.h>

@class LYToastView, LYToastViewMananger;

@protocol LYToastViewManangerDelegate <NSObject>
@optional
//如果想用按钮的那几种样式弄得用这几个
- (void)toastViewManager:(LYToastViewMananger *)manager ButtonTouchDown:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager ButtonTouchUpInside:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager ButtonTouchUpOutside:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager ButtonTouchDragExit:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager ButtonTouchDragEnter:(UIButton *)button;

//如果想按照需求来的话用这个几个  
- (void)toastViewManager:(LYToastViewMananger *)manager beginSpeakingWithButton:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager didFinishedSpeakingWithButton:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager cancelSpeakingWithButton:(UIButton *)button;
- (void)toastViewManager:(LYToastViewMananger *)manager speakingTimeOutWithButton:(UIButton *)button;

//如果想使用这个，必须设置ifHaveTimeLessMode = YES
- (void)toastViewManager:(LYToastViewMananger *)manager speakingTimeLessThanOneSecondWithButton:(UIButton *)button;

@end

@interface LYToastViewMananger : NSObject

#ifdef K_TEST
//暂时测试用的属性 没用
@property (nonatomic, strong) UISwitch *ly_switch;
@property (nonatomic, strong) NSURL    *url;
#endif

////////////////////////////////////////////////////

+ (LYToastViewMananger *)shareManager;

- (void)showToastViewInView:(UIView *)view
                speakButton:(UIButton *)button
                   delegate:(id<LYToastViewManangerDelegate>)delegate
                   recorder:(AVAudioRecorder *)recorder;

//设置view的位置
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) BOOL    ifHaveTimeLessMode; //default is NO
@end

@interface LYToastView : UIView

@property (readwrite, nonatomic, copy)   NSString   *text;
@property (readwrite, nonatomic, strong) UIImage    *image;
@property (readwrite, nonatomic, strong) UIColor    *labelColor;

+ (LYToastView *)defaultView;
+ (LYToastView *)viewWithImage:(UIImage *)image
                     labelText:(NSString *)text
                 timeUpHandler:(void(^)(LYToastView *toastView))handler;
@end


