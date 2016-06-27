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
@interface MovieViewController ()<PlayerViewDelegate>
{
    PlayerView *_playerView;
    BOOL _isVertical;//是否是竖屏小view
}

@property (retain, nonatomic) AVPlayer *player;
@property (nonatomic ,retain) AVPlayerItem *playerItem;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _isVertical = YES;
    [self makeUpPlayerView];
}
#pragma mark - 初始化
- (void)makeUpPlayerView {
    _playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
    _playerView.gd_delegate = self;
    _playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerView];
    
//    NSURL *videoUrl = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
//    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
    
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];////当缓冲进度有变化的时候
    
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];//当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
    
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];//当没有任何缓冲部分可以播放的时候
    
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];//获取到视频的大小的时候调用
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    _playerView.player = self.player;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self playBtn];

    
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;//横屏
}
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

#pragma mark - gd_deledate
- (void)playerBtndidClicked:(UIButton *)sender{

    if (sender.tag == FULLBUTTON_TAG) {
#if 1
        if (_isVertical) {
            

            [self.view bringSubviewToFront:_playerView];
            [UIView animateWithDuration:0.3 animations:^{
                self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
                self.navigationController.view.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
                [[UIApplication sharedApplication] setStatusBarHidden:YES];

                _playerView.frame = CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH);
//                _playerView.center = CGPointMake(SCREENHEIGHT/2, SCREENWIDTH/2);
//                _playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
                [_playerView clearViewUpdate_scaleScreen];
            } completion:^(BOOL finished) {
                _isVertical = NO;
//
            }];
        }else {
            [UIView animateWithDuration:0.3 animations:^{
                self.navigationController.view.transform = CGAffineTransformIdentity;
                self.navigationController.view.frame = [UIScreen mainScreen].bounds;
                [[UIApplication sharedApplication] setStatusBarHidden:NO];

//                _playerView.transform = CGAffineTransformMakeRotation(0);
                _playerView.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
//                _playerView.center = CGPointMake(SCREENWIDTH/2, 100);
                [_playerView clearViewUpdate_scaleScreen];
            } completion:^(BOOL finished) {
                _isVertical = YES;
//
            }];
        }
#endif
    }
    
}
#pragma mark - 临时播放按钮
- (void)playBtn{
    UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
    play.frame = CGRectMake(20, 320, 100, 50);
    [play setTitle:@"Play" forState:UIControlStateNormal];
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
    if ([keyPath isEqualToString:@"status"]) {        //获取到视频信息的状态, 成功就可以进行播放, 失败代表加载失败
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {   //准备好播放
            GDLog(@"贮备好播放");
        }else if(self.playerItem.status == AVPlayerItemStatusFailed){    //加载失败
            NSLog(@"AVPlayerItemStatusFailed: 视频播放失败");
        }else if(self.playerItem.status == AVPlayerItemStatusUnknown){   //未知错误
            GDLog(@"未知错误");
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
#if 0
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        NSLog(@"Time Interval:%f,totla:%f",timeInterval,totalDuration);
//        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
#endif
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){ //当视频播放因为各种状态播放停止的时候, 这个属性会发生变化
        GDLog(@"playbackLikelyToKeepUp");
        
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){  //当没有任何缓冲部分可以播放的时候
       
        NSLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackBufferFull"]){
        
        NSLog(@"playbackBufferFull: change : %@", change);
        
    }else if([keyPath isEqualToString:@"presentationSize"]){      //获取到视频的大小的时候调用
        CGSize size = _playerItem.presentationSize;
        //适应电影播放尺寸的大小
        _playerView.frame = CGRectMake(0, 64, SCREENWIDTH, (SCREENWIDTH*size.height)/size.width);
    }
    
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
}
- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"presentationSize" context:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
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
    self.navigationController.navigationBarHidden = YES;
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
