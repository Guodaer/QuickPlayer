//
//  PlayerView.h
//  QuickPlayer
//
//  Created by xiaoyu on 16/6/24.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define FULLBUTTON_TAG 2000

@protocol PlayerViewDelegate <NSObject>
- (void)playerBtndidClicked:(UIButton *)sender;
@end

@interface PlayerView : UIView
{
    
}
@property (nonatomic, assign) id<PlayerViewDelegate>gd_delegate;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UISlider *videoSlider;//控制视频
@property (nonatomic, strong) UIProgressView *videoLoadProgressView;//背景缓存进度

@property (nonatomic, strong) UIView *clearView;
@property (nonatomic ,strong) UIView *topView;
@property (nonatomic, strong) UIView *underView;

- (void)clearViewUpdate_scaleScreen;

@end
