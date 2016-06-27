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
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    GDLog(@"drawRect");
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
- (void)clearViewUpdate_scaleScreen {
    _clearView.frame = self.bounds;
}

#pragma mark - 轻触手势
- (void)clearViewTapGesture:(UITapGestureRecognizer *)tab {
    if (_isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            _topView.alpha = 1;
            _underView.alpha = 1;
        } completion:^(BOOL finished) {
            _isHidden = NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _topView.alpha = 0;
            _underView.alpha = 0;
        } completion:^(BOOL finished) {
            _isHidden = YES;
        }];
    }
}
#pragma mark - 上线两块View
- (void)setupControlView {
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    _topView.userInteractionEnabled = YES;
    _topView.backgroundColor = XUIColor(0xffffff, 0.5);
    _topView.alpha = 0;
    [_clearView addSubview:_topView];
    
    _underView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-44, self.frame.size.width, 44)];
    _underView.userInteractionEnabled = YES;
    _underView.backgroundColor = XUIColor(0xffffff, 0.5);
    _underView.alpha = 0;
    [_clearView addSubview:_underView];
    [self drawViewCotrol];
}
- (void)drawViewCotrol {
    
    //全屏按钮
    UIButton *fullViewbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullViewbutton.frame = CGRectMake(self.frame.size.width - 50, 7, 40, 30);
    [fullViewbutton setTitle:@"size" forState:UIControlStateNormal];
    fullViewbutton.titleLabel.font = [UIFont systemFontOfSize:13];
    [fullViewbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fullViewbutton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [fullViewbutton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    fullViewbutton.tag = FULLBUTTON_TAG;
    [_underView addSubview:fullViewbutton];
    
}
#pragma mark - 点击事件
- (void)btnClick:(UIButton *)sender {
    if ([_gd_delegate respondsToSelector:@selector(playerBtndidClicked:)]) {
        [_gd_delegate playerBtndidClicked:sender];
    }
}
#pragma mark - Setting方法
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
    _videoLoadProgressView.progress = videoLoadProgressView.progress;
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
