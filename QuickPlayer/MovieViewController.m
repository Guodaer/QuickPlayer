//
//  MovieViewController.m
//  QuickPlayer
//
//  Created by xiaoyu on 16/6/23.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "MovieViewController.h"
#import <AVKit/AVKit.h>
#import "GD_CustomCenter.h"
#import "PlayerView.h"
#define PlayerViewFrame(width,height) CGRectMake(0, 20, width, height)
#define PlayerUrl @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"
NSString * const Player_Status = @"status";                                 //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
NSString * const Player_LoadedTimeRanges = @"loadedTimeRanges";             //当缓冲进度有变化的时候
NSString * const Player_PlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp"; //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
NSString * const Player_PlaybackBufferEmpty = @"playbackBufferEmpty";       //当没有任何缓冲部分可以播放的时候
NSString * const Player_PlaybackBufferFull = @"playbackBufferFull";         //缓冲完成
NSString * const Player_PresentationSize = @"presentationSize";             //获取到视频的大小的时候调用

@interface MovieViewController ()<PlayerViewDelegate>
{
    BOOL _isVertical;//是否是竖屏小view
    BOOL _isPlay;   //是否播放
    //判断是否为第一次布局
    BOOL _isFisrtConfig;
}

@property (retain, nonatomic) AVPlayer *player;
@property (nonatomic ,retain) AVPlayerItem *playerItem;
@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) UIButton *systemReturnBtn;
@property (nonatomic, strong) id timerObserver;//用来监控播放时间的observer
@property (nonatomic, assign) BOOL sliderValueChanging; //判断滑块是否滑动

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _isVertical = YES;
    _isFisrtConfig = YES;
    _isPlay = NO;
    _sliderValueChanging = NO;
    [self makeUpPlayerView];
    self.systemReturnBtn.hidden = NO;

}
- (BOOL)shouldAutorotate{
    return YES;
}
- (UIButton *)systemReturnBtn{
    if (!_systemReturnBtn) {
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
        blackView.backgroundColor = XUIColor(0x000000, 0.9);
        [self.view addSubview:blackView];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 23, 40, 40);
        [button setImage:XUIImage(@"returnBtn") forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 20)];
        [button addTarget:self action:@selector(returnButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _systemReturnBtn = button;
    }
    [self.view bringSubviewToFront:_systemReturnBtn];
    return _systemReturnBtn;
}
- (void)returnButton:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 初始化
- (void)makeUpPlayerView {
    _playerView = [[PlayerView alloc] initWithFrame:PlayerViewFrame(SCREENWIDTH, 250)];
    _playerView.gd_delegate = self;
    _playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerView];
#if 1
    NSURL *videoUrl = [NSURL URLWithString:PlayerUrl];
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
#endif
    [self.playerItem addObserver:self forKeyPath:Player_Status options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:Player_LoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:Player_PlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.playerItem addObserver:self forKeyPath:Player_PlaybackBufferEmpty options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.playerItem addObserver:self forKeyPath:Player_PlaybackBufferFull options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.playerItem addObserver:self forKeyPath:Player_PresentationSize options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    _playerView.player = self.player;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self playBtn];
    
}
#pragma mark - 旋转的通知
-(void)orientationChanged:(NSNotification *)notification{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            GDLog(@"Portrait");
            break;
        case UIDeviceOrientationLandscapeLeft:
            GDLog(@"Left");
            break;
        case UIDeviceOrientationLandscapeRight:
            GDLog(@"Right");
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            GDLog(@"UpsideDown");
            break;
        default:
            break;
    }
}

#pragma mark - gd_deledate
- (void)playerBtndidClicked:(UIButton *)sender{

    if (sender.tag == FULLBUTTON_TAG) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val;
            [self.view bringSubviewToFront:_playerView];
            if (_isVertical) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                val = UIInterfaceOrientationLandscapeRight;
                _playerView.frame = CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH);
                [_playerView clearViewUpdate_scaleScreen];
                _playerView.topView.frame = CGRectMake(0, 0, SCREENHEIGHT, 50);
                _playerView.underView.frame = CGRectMake(0, SCREENWIDTH-50, SCREENHEIGHT, 50);
                _playerView.isPortrait = NO;
                [_playerView InterfaceOrientationLandscapeLeft];
                _isVertical = NO;
            }
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }else if (sender.tag == ReturnFullBtn_Tag){
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val;
            [self.view bringSubviewToFront:_playerView];
            
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            val = UIInterfaceOrientationPortrait;
            _playerView.frame = CGRectMake(0, 20, SCREENHEIGHT, 250);
            [_playerView clearViewUpdate_scaleScreen];
            _playerView.topView.frame = CGRectMake(0, 0, SCREENHEIGHT, 44);
            _playerView.underView.frame = CGRectMake(0, 250-44, SCREENHEIGHT, 44);
            _playerView.isPortrait = YES;
            [_playerView InterfaceOrientationPortraitor];
            _isVertical = YES;
            self.systemReturnBtn.hidden = NO;
            
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        
    }else if (sender.tag == PlayButton_Tag){
        if (_isPlay) {
            [self changeState:@"play_start"];
        }
        else {
            [self changeState:@"play_pause"];
        }
    }
    
}
- (void)changeState:(NSString *)imgName {
    if ([imgName isEqualToString:@"play_start"]) {
        [self.player pause];
        _isPlay = NO;
    }else if ([imgName isEqualToString:@"play_pause"]){
        [self.player play];_isPlay = YES;
    }
    [_playerView.playButton setImage:XUIImage(imgName) forState:UIControlStateNormal];
}

#pragma mark - 临时播放按钮
- (void)playBtn{
    UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
    play.frame = CGRectMake(20, 320, 100, 50);
    [play setTitle:@"temp" forState:UIControlStateNormal];
    [play setBackgroundImage:[self createImageWithColor:XUIColor(0x3b5286, 1)] forState:UIControlStateNormal];
    [play setBackgroundImage:[self createImageWithColor:XUIColor(0x3b5286, 0.75)] forState:UIControlStateHighlighted];
    play.layer.cornerRadius = 4;
    play.clipsToBounds = YES;
    [play addTarget:self action:@selector(playpausebtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:play];
}
- (void)playpausebtn:(UIButton *)sender{
    [self.player play];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:Player_Status]) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            GDLog(@"贮备好播放");
            if (!_isPlay) {
                [self changeState:@"play_pause"];
            }
            if (_isFisrtConfig) {
                [self readyToObserverSlider];//监控播放进度
            }
        }else if(self.playerItem.status == AVPlayerItemStatusFailed){    //加载失败
            [self changeState:@"play_start"];
        }else if(self.playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
            [self changeState:@"play_start"];
        }
    }else if([keyPath isEqualToString:Player_LoadedTimeRanges]){ //当缓冲进度有变化的时候

        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [_playerView.videoLoadProgressView setProgress:timeInterval/totalDuration animated:YES];

    }else if ([keyPath isEqualToString:Player_PlaybackLikelyToKeepUp]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
    }else if([keyPath isEqualToString:Player_PlaybackBufferEmpty]){  //当没有任何缓冲部分可以播放的时候
        [self changeState:@"play_start"];
    }else if ([keyPath isEqualToString:Player_PlaybackBufferFull]){
        
        NSLog(@"playbackBufferFull: change : %@", change);
        
    }else if([keyPath isEqualToString:Player_PresentationSize]){      //获取到视频的大小的时候调用
//       CGSize size = _playerItem.presentationSize;
    }
    
}
#pragma mark - 手动操作slider
- (void)pansSlider_controlMovieProgress {
    __weak typeof(self) weakSelf = self;
    _playerView.SliderValuePans= ^(float value){
        [weakSelf seekToTheTimeValue:value];
    };
    _playerView.SliderTouchInside = ^(float state) {
        weakSelf.sliderValueChanging = NO;
    };
    
}
//跳转到指定位置
-(void)seekToTheTimeValue:(float)value{
    _sliderValueChanging = YES;
    [self.player pause];
    float totalDuration = CMTimeGetSeconds(self.playerItem.duration);
    float current = totalDuration*value;
    CMTime changedTime = CMTimeMakeWithSeconds(current, 1);
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished){
        if (!weakSelf.sliderValueChanging) {
            [weakSelf.player play];
            [self changeState:@"play_pause"];
        }
        //更改avplayerView的播放状态, 并且改变button上的图片
    }];
}
/**
 *  监控播放进度
 */
- (void)readyToObserverSlider {
    [self pansSlider_controlMovieProgress];
    CMTime duration = self.playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    __weak typeof(self) weakSelf = self;
    self.timerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        long long currentSecond = weakSelf.playerItem.currentTime.value/weakSelf.playerItem.currentTime.timescale;
        if (!weakSelf.sliderValueChanging) {
            weakSelf.playerView.videoSlider.value = currentSecond/totalDuration;
        }
    }];
    
}
#pragma mark - 计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 当前视频播放完毕
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    [self changeState:@"play_start"];
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:Player_Status context:nil];
    [self.playerItem removeObserver:self forKeyPath:Player_LoadedTimeRanges context:nil];
    [self.playerItem removeObserver:self forKeyPath:Player_PlaybackLikelyToKeepUp context:nil];
    [self.playerItem removeObserver:self forKeyPath:Player_PlaybackBufferEmpty context:nil];
    [self.playerItem removeObserver:self forKeyPath:Player_PlaybackBufferFull context:nil];
    [self.playerItem removeObserver:self forKeyPath:Player_PresentationSize context:nil];
    if (_timerObserver) {
        [self.player removeTimeObserver:self.timerObserver];
        _timerObserver = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
