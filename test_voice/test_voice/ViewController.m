//
//  ViewController.m
//  VoiceBtn_test
//
//  Created by 刘杨 on 15/11/13.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import "LYToastView.h"

@interface ViewController ()<LYToastViewManangerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *ly_switch;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    LYToastViewMananger *manager = [LYToastViewMananger shareManager];
    [manager showToastViewInView:self.view speakButton:self.button delegate:self recorder:self.recorder];
#ifdef K_TEST
    manager.url = self.url;
    manager.ly_switch = self.ly_switch;
#endif
//    manager.ifHaveTimeLessMode = YES;
//    manager.centerY = 0.8 * self.view.bounds.size.height;

}



- (void)toastViewManager:(LYToastViewMananger *)manager beginSpeakingWithButton:(UIButton *)button{
    NSLog(@"%s", __func__);
    [self.recorder prepareToRecord];
    [self.recorder record];
}
- (void)toastViewManager:(LYToastViewMananger *)manager didFinishedSpeakingWithButton:(UIButton *)button{
    NSLog(@"%s", __func__);
}
- (void)toastViewManager:(LYToastViewMananger *)manager speakingTimeOutWithButton:(UIButton *)button{
    NSLog(@"%s", __func__);
}
- (void)toastViewManager:(LYToastViewMananger *)manager cancelSpeakingWithButton:(UIButton *)button{
    NSLog(@"%s", __func__);
}
- (void)toastViewManager:(LYToastViewMananger *)manager speakingTimeLessThanOneSecondWithButton:(UIButton *)button{
    NSLog(@"%s", __func__);    
}


- (AVAudioRecorder *)recorder{
    if (!_recorder) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:@"/var/mobile/Containers/Data/Application/5DBDC4BC-B969-47CB-8D22-34325EBCD0CC/Documents/file.aac"] error:nil];
        
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"成功");
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"我知道了", nil];
                    [alert show];
                });
            }
        }];
        
        NSError *error = nil;
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [session setActive:YES error:&error];
        
        
        NSDictionary *dict = @{
                               AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                               AVSampleRateKey : [NSNumber numberWithInt:8000],
                               AVNumberOfChannelsKey : [NSNumber numberWithInt:1],
                               AVLinearPCMBitDepthKey : [NSNumber numberWithInt:16],
                               AVLinearPCMIsBigEndianKey : [NSNumber numberWithBool:NO],
                               AVLinearPCMIsFloatKey : [NSNumber numberWithBool:NO]
                               };
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.url = [NSURL URLWithString:[path stringByAppendingString:@"/file.aac"]];
        
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.url
                                                    settings:dict
                                                       error:&error];
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}





//下面两个方法会在各自区域频繁的调用
//dragInside里面要更改为原来的状态
- (IBAction)dragInside:(id)sender {
}
//dragOutside里面要提示松开手指取消发送
- (IBAction)dragOutside:(id)sender {
}

@end
