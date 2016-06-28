//
//  PlayerView.m
//  QuickPlayer
//
//  Created by xiaoyu on 16/6/24.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "PlayerView.h"
#import "GD_CustomCenter.h"
@interface PlayerView () {
  
    BOOL _isHidden;
}

@end

@implementation PlayerView

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isPortrait = YES;
        _isHidden = YES;
        self.userInteractionEnabled = YES;
        _clearView = [[UIView alloc] initWithFrame:self.bounds];
        _clearView.backgroundColor = [UIColor clearColor];
        _clearView.userInteractionEnabled = YES;
        [self addSubview:_clearView];
        [self setupControlView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearViewTapGesture:)];
        [_clearView addGestureRecognizer:tap];
    }
    return self;
}
- (void)clearViewUpdate_scaleScreen {
    _clearView.frame = self.bounds;
}
#pragma mark - 轻触手势
- (void)clearViewTapGesture:(UITapGestureRecognizer *)tab {
    if (_isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [self isPortraitorLandscapeRight];
            _underView.alpha = 1;
        } completion:^(BOOL finished) {
            _isHidden = NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _topView.alpha = 0;
            _underView.alpha = 0;
            if (!_isPortrait) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
        } completion:^(BOOL finished) {
            _isHidden = YES;
        }];
    }
}
#pragma mark - 判断是竖屏还是横屏tap
- (void)isPortraitorLandscapeRight {
    if (_isPortrait) {
        _topView.alpha = 0;
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        _topView.alpha = 1;
    }
}
#pragma mark - 变竖屏
- (void)InterfaceOrientationPortraitor {
    _topView.alpha = 0;
    [self hideWhatyouwantwithTag:FULLBUTTON_TAG Alpha:1];
    [self playerBtnFrame:CGRectMake(4, 0, 44, 44)
             SliderFrame:CGRectMake(48+3, 0, SCREENHEIGHT-106, 44)
           ProgressFrame:CGRectMake(48+5, 21, SCREENHEIGHT-108, 2)];
    _timeLabel.hidden = YES;
}
#pragma mark - 变横屏
- (void)InterfaceOrientationLandscapeLeft {
    if (!_isHidden) {
        [self isPortraitorLandscapeRight];
    }
    [self hideWhatyouwantwithTag:FULLBUTTON_TAG Alpha:0];
    [self playerBtnFrame:CGRectMake(4, 0, 50, 50)
             SliderFrame:CGRectMake(54+78, 0, SCREENHEIGHT-106-75, 50)
           ProgressFrame:CGRectMake(54+80, 24, SCREENHEIGHT-110-75, 2)];
    _timeLabel.hidden = NO;
}
#pragma mark - playerButton Slider  ProgressView 拉伸
- (void)playerBtnFrame:(CGRect)playerframe SliderFrame:(CGRect)sliderframe ProgressFrame:(CGRect)proframe {
    _playButton.frame = playerframe;
    _videoSlider.frame = sliderframe;
    _videoLoadProgressView.frame = proframe;
}
#pragma mark - 隐藏还是appear
- (void)hideWhatyouwantwithTag:(NSInteger)tag Alpha:(NSInteger)alpha{
    UIView *view = [self viewWithTag:tag];
    view.alpha = alpha;
}
#pragma mark - 上下两块View
- (void)setupControlView {
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    _topView.userInteractionEnabled = YES;
    _topView.backgroundColor = XUIColor(0xffffff, 0.13);
    _topView.alpha = 0;
    [_clearView addSubview:_topView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 13, 40, 40);
    [button setImage:XUIImage(@"returnBtn") forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 20)];
    button.tag = ReturnFullBtn_Tag;
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:button];
    
    _underView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-44, self.frame.size.width, 44)];
    _underView.userInteractionEnabled = YES;
    _underView.backgroundColor = XUIColor(0xffffff, 0.15);
    _underView.alpha = 0;
    [_clearView addSubview:_underView];
    [self drawViewCotrol];
}
- (void)drawViewCotrol {
    //全屏按钮
    UIButton *fullViewbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullViewbutton.frame = CGRectMake(self.frame.size.width - 40, 4.5, 35, 35);
    [fullViewbutton setImage:XUIImage(@"play_full") forState:UIControlStateNormal];
    [fullViewbutton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    fullViewbutton.tag = FULLBUTTON_TAG;
    [_underView addSubview:fullViewbutton];
    
    //开始暂停按钮
    UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
    play.frame = CGRectMake(4, 0, 44, 44);
    [play setImage:XUIImage(@"play_start") forState:UIControlStateNormal];
    play.tag = PlayButton_Tag;
    [play addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _playButton = play;
    [_underView addSubview:_playButton];
    //缓存进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(CGRectGetMaxX(_playButton.frame)+5, 21, SCREENWIDTH-110, 44);
    progressView.progress = 0.0f;
    progressView.progressTintColor = [UIColor grayColor];
    _videoLoadProgressView = progressView;
    [_underView addSubview:_videoLoadProgressView];
    
    //播放进度
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame)+3, 0, SCREENWIDTH-106, 44)];
    [slider addTarget:self action:@selector(sliderlog:) forControlEvents:UIControlEventValueChanged];
    slider.maximumTrackTintColor = [UIColor clearColor];
    _videoSlider = slider;
    [_underView addSubview:_videoSlider];
    [_underView bringSubviewToFront:_videoSlider];
    
    //timelabel
    _timeLabel = [self time_Label];
    _timeLabel.hidden = YES;
    [_underView addSubview:_timeLabel];
    
}
- (UILabel *)time_Label{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame)+5, 0, 80, 50)];
    label.textColor = XUIColor(0xffffff, 0.85);
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"0:00/10:00";
    return label;
}
#pragma mark - slider滑动
- (void)sliderlog:(UISlider*)slider {
    GDLog(@"%lf",slider.value);
}
#pragma mark - 点击事件
- (void)btnClick:(UIButton *)sender {
    if ([_gd_delegate respondsToSelector:@selector(playerBtndidClicked:)]) {
        [_gd_delegate playerBtndidClicked:sender];
    }
}
#pragma mark - Setting方法
- (void)setTimeLabel:(UILabel *)timeLabel{
    _timeLabel = timeLabel;
}
- (void)setPlayButton:(UIButton *)playButton {
    _playButton = playButton;
}
- (void)setIsPortrait:(BOOL)isPortrait{
    _isPortrait = isPortrait;
}
- (void)setClearView:(UIView *)clearView {
    _clearView = clearView;
}
- (void)setTopView:(UIView *)topView {
    _topView = topView;
}
- (void)setUnderView:(UIView *)underView{
    _underView = underView;
}
- (void)setVideoSlider:(UISlider *)videoSlider{
    _videoSlider.value = videoSlider.value;
}
- (void)setVideoLoadProgressView:(UIProgressView *)videoLoadProgressView{
    _videoLoadProgressView = videoLoadProgressView;
}
+ (Class)layerClass{
    return [AVPlayerLayer class];
}
- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
