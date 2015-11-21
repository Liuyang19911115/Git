//
//  LYToastView.m
//  VoiceBtn_test
//
//  Created by 刘杨 on 15/11/13.
//  Copyright © 2015年 刘杨. All rights reserved.
//
#define K_COLOR_RGB(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:(a)]
#define K_SET_ZERO 0
#define K_TEN      10

#import "LYToastView.h"

@interface LYToastViewMananger()<UIAlertViewDelegate, AVAudioRecorderDelegate>

#ifdef K_TEST
@property (nonatomic, strong) AVAudioPlayer *player;
#endif

/**下面是有用的*/
@property (nonatomic, strong) LYToastView                   *toast;
@property (nonatomic, strong) NSArray                       *img_array;
@property (nonatomic, strong) UIButton                      *button;
@property (nonatomic, strong) UIView                        *view;
@property (nonatomic, strong) AVAudioRecorder               *recorder;
@property (nonatomic, strong) NSTimer                       *timer;
@property (nonatomic, weak) id<LYToastViewManangerDelegate> delegate;
@end

@implementation LYToastViewMananger{
    float _recorderTime;
    BOOL  _isSend;
}

+ (LYToastViewMananger *)shareManager{
    static LYToastViewMananger *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (void)showToastViewInView:(UIView *)view
                speakButton:(UIButton *)button
                   delegate:(id<LYToastViewManangerDelegate>)delegate
                   recorder:(AVAudioRecorder *)recorder{
    
    self.delegate = delegate;
    self.view = view;
    self.button = button;
    self.recorder = recorder;
    self.recorder.delegate = self;
    
    self.button.tintColor = [UIColor clearColor];
        
    [self.button setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.button setTitle:@"松开手指, 确认发送" forState:UIControlStateHighlighted];
    [self.button setTitle:@"松开手指, 取消发送" forState:UIControlStateSelected];
    
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.button addTarget:self action:@selector(buttonTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self.button addTarget:self action:@selector(buttonTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
}

//button点击事件
- (void)buttonTouchUpInside:(UIButton *)sender{
    sender.selected = NO;
    if (_recorderTime < 1 && 0 != _ifHaveTimeLessMode) {
        ///给他用户交互关了
        sender.userInteractionEnabled = NO;
        [self timerStopIsPlay:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:speakingTimeLessThanOneSecondWithButton:)]) {
            [self.delegate toastViewManager:self speakingTimeLessThanOneSecondWithButton:self.button];
        }
        
        self.toast.image = nil;//替换为一个叹号
        self.toast.text = @"录音时间太短";

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.toast removeFromSuperview];
            sender.userInteractionEnabled = YES;//给丫打开用户交互
        });
    }else if(!_isSend){
        [self timerStopIsPlay:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:didFinishedSpeakingWithButton:)]) {
            [self.delegate toastViewManager:self didFinishedSpeakingWithButton:self.button];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchUpInside:)]) {
            [self.delegate toastViewManager:self ButtonTouchUpInside:self.button];
        }
        [self.toast removeFromSuperview];
    }
    _recorderTime = K_SET_ZERO;
    _isSend = NO;
}
- (void)buttonTouchUpOutside:(UIButton *)sender{
    sender.selected = NO;
    [self timerStopIsPlay:NO];
    [self.toast removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:cancelSpeakingWithButton:)]) {
        [self.delegate toastViewManager:self cancelSpeakingWithButton:self.button];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchUpOutside:)]) {
        [self.delegate toastViewManager:self ButtonTouchUpOutside:self.button];
    }
    _recorderTime = K_SET_ZERO;
    _isSend = NO;
}
- (void)buttonTouchDown:(UIButton *)sender{//开启录音和加载视图
    sender.selected = NO;
    
#ifdef K_TEST
    [self beginTimerToArchive];
#endif
    
    [self addVoiceViewToView:self.view];
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:beginSpeakingWithButton:)]) {
        [self.delegate toastViewManager:self beginSpeakingWithButton:self.button];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDown:)]) {
        [self.delegate toastViewManager:self ButtonTouchDown:self.button];
    }
    if (self.img_array) self.toast.image = self.img_array.firstObject;
}
- (void)buttonTouchDragEnter:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDragEnter:)]) {
        [self.delegate toastViewManager:self ButtonTouchDragEnter:self.button];
    }
    
    [self beginTimerToArchive];
    
    sender.selected = NO;
    self.toast.labelColor = [UIColor clearColor];
    self.toast.text = @"手指上滑, 取消发送";
}
- (void)buttonTouchDragExit:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:ButtonTouchDragExit:)]) {
        [self.delegate toastViewManager:self ButtonTouchDragExit:self.button];
    }
    
    self.toast.image = nil;//替换为一个图片
    [self.timer invalidate];
    self.timer = nil;
    
    sender.selected = YES;
    self.toast.labelColor = K_COLOR_RGB(232, 106, 109, 0.8);
    self.toast.text = @"松开手指, 取消发送";
}

//开启定时器
- (void)beginTimerToArchive{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeRefresh) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)addVoiceViewToView:(UIView *)view{
    
    self.toast = [LYToastView viewWithImage:self.img_array.firstObject
                                  labelText:@"手指上滑, 取消发送"
                              timeUpHandler:^(LYToastView *toastView) {
                                  [self timerStopIsPlay:YES];
                                  if (self.delegate && [self.delegate respondsToSelector:@selector(toastViewManager:speakingTimeOutWithButton:)]) {
                                      [self.delegate toastViewManager:self
                                            speakingTimeOutWithButton:self.button];
                                      _isSend = YES;
                                  }
                              }];
    self.toast.width = self.width ?: 160;
    self.toast.height = self.height ?: 160;
    self.toast.centerX = self.centerX ?: view.centerX;
    self.toast.centerY = self.centerY ?: view.centerY;
    [view addSubview:self.toast];
    
}

- (NSArray *)img_array{
    if (!_img_array) {
        _img_array = [NSArray arrayWithObjects:[UIImage imageNamed:@"toast_view_img_1"],
                      [UIImage imageNamed:@"toast_view_img_2"],
                      [UIImage imageNamed:@"toast_view_img_3"],
                      [UIImage imageNamed:@"toast_view_img_4"],
                      [UIImage imageNamed:@"toast_view_img_5"],
                      [UIImage imageNamed:@"toast_view_img_6"],
                      [UIImage imageNamed:@"toast_view_img_7"],
                      [UIImage imageNamed:@"toast_view_img_8"],nil];
    }
    return _img_array;
}

- (void)timeRefresh{
    [self.recorder updateMeters];
    float number = [self.recorder averagePowerForChannel:0];
    NSLog(@"average: %f", number);
    if (self.img_array.count > 0) {
        if (number >= - 40 && number < - 35) {
            self.toast.image = self.img_array[0];
        }else if (number >= - 35 && number < - 30){
            self.toast.image = self.img_array[0];
        }else if (number >= - 30 && number < - 25){
            self.toast.image = self.img_array[1];
        }else if (number >= - 25 && number < - 20){
            self.toast.image = self.img_array[2];
        }else if (number >= - 20 && number < - 15){
            self.toast.image = self.img_array[3];
        }else if (number >= - 15 && number < - 10){
            self.toast.image = self.img_array[4];
        }else if (number >= - 10 && number < - 5){
            self.toast.image = self.img_array[5];
        }else if (number >= - 5 && number < -2){
            self.toast.image = self.img_array[6];
        }else if (number >= - 2){
            self.toast.image = self.img_array[7];
        }
    }
    if (self.ifHaveTimeLessMode) {
        _recorderTime += 0.1;
    }
    NSLog(@"录音时间 秒 %f", _recorderTime);
}

//完成定时器并播放
- (void)timerStopIsPlay:(BOOL)play{
    [self.recorder stop];
    _recorderTime = K_SET_ZERO;
    [self.timer invalidate];
    self.timer = nil;
    
#pragma mark - 没用
#ifdef K_TEST
    if (play) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"播放?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"comfirm", nil];
        [alert show];
    }
#endif
}

#pragma mark - 没用
#ifdef K_TEST
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        [self.player play];
    }
}
#endif

#pragma mark - 没用
#ifdef K_TEST
///完成录音的回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    NSLog(@"==================================== \n %@ \n=========================", NSStringFromSelector(_cmd));
    AVAudioSession *session = [AVAudioSession sharedInstance];

    AVAudioSessionPortOverride audioRouteOverride = [self.ly_switch isOn] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;

    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    BOOL isSuccess = [session overrideOutputAudioPort:audioRouteOverride error:&error];
    [session setActive:YES error:&error];
    NSLog(@"成功？ %d %@", isSuccess,error);
}
#endif
@end

@interface LYToastView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *text_label;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation LYToastView{
    int _time;
    int _left_time;
    void(^_handler)(LYToastView *);
}

+ (LYToastView *)defaultView{
    static LYToastView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

+ (LYToastView *)viewWithImage:(UIImage *)image
                     labelText:(NSString *)text
                 timeUpHandler:(void (^)(LYToastView *))handler{
    LYToastView *view = [LYToastView defaultView];
    [view setTimeUpHandler:handler];
    [view beginTimer];//开启定时器
    [view setValuesWithImage:image text:text];
    return view;
}

- (void)setTimeUpHandler:(void(^)(LYToastView *))handler{
    _handler = [handler copy];
}

- (void)beginTimer{
    //开启定时器
    _time = K_SET_ZERO;
    _left_time = K_TEN;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        [self initialized];
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}

- (void)setText:(NSString *)text{
    _text = text;
    self.text_label.text = text;
}

- (void)setLabelColor:(UIColor *)labelColor{
    _labelColor = labelColor;
    self.text_label.backgroundColor = labelColor;
}

- (void)setValuesWithImage:(UIImage *)image text:(NSString *)text{
    self.image = image;
    self.text = text;
    
    self.imageView.image = self.image;
    self.text_label.text = self.text;
}

- (void)initialized{
    [self addSubview:self.containerView];
    [self addSubview:self.imageView];
    [self addSubview:self.text_label];
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(calculateTime:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return _timer;
}

- (void)calculateTime:(NSTimer *)sender{

    if (49 <= _time) {
        self.text_label.text = [NSString stringWithFormat:@"倒计时%d秒", _left_time--];
        if (60 < _time || -1 > _left_time) {
            [self removeFromSuperview];
            if (_handler) {
                _handler(self);
            }
        }
    }
    _time ++;
    
    NSLog(@"%d", _time);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    CGFloat margin = 10;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.imageView.x = margin;
    self.imageView.y = margin;
    self.imageView.width = width - margin * 2;
    self.imageView.height = height - margin * 6;
    
    self.text_label.x = margin;
    self.text_label.y = self.imageView.height + margin * 2;
    self.text_label.width = self.imageView.width;
    self.text_label.height = margin * 3;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = K_COLOR_RGB(24, 24, 24, 0.6);
    }
    return _containerView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)text_label{
    if (!_text_label) {
        _text_label = [[UILabel alloc] init];
        _text_label.backgroundColor = [UIColor clearColor];
        _text_label.textAlignment = NSTextAlignmentCenter;
        _text_label.font = [UIFont systemFontOfSize:15];
        _text_label.textColor = [UIColor whiteColor];
        _text_label.layer.cornerRadius = 5;
        _text_label.layer.masksToBounds = YES;
    }
    return _text_label;
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    
    self.text = nil;
    self.labelColor = [UIColor clearColor];
    
    [self.timer invalidate];
    self.timer = nil;
    _time = K_SET_ZERO;
    _left_time = K_SET_ZERO;
    self.text_label.text = nil;
}

@end
