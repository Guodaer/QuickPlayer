//
//  GD_CustomCenter.h
//  XUIPhone
//
//  Created by xiaoyu on 15/11/24.
//  Copyright © 2015年 guoda. All rights reserved.
//

#ifndef GD_CustomCenter_h
#define GD_CustomCenter_h
#import "AppDelegate.h"


/**3
 *  屏幕的大小
 */
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

/**
 *  设置图片
 *
 *  @param X 图片名称
 *
 *  @return UIImage类型的
 */
#define XUIImage(X) [UIImage imageNamed:X]

/**
 *  加在本地图片
 *
 *  @param x 图片名称
 *
 *  @return UIImage
 */
#define XUILocalImage(x) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:x ofType:@"png"]]
/**
 *  颜色0x------
 *
 *  @param rgbValue
 *
 *  @return UIColor
 */
#define XUIColor(rgbValue,alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

//#define SystemColor 0x3B5286
/**
 *  默认颜色
 *
 *  @param alpha 透明度
 *
 *  @return 默认颜色
 */
#define rgbValue 0x3b5286
#define SystemColor(alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha]

/**
 *  判断设备型号
*/
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_MAX_LENGTH (MAX(SCREENWIDTH, SCREENHEIGHT))
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6p (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#ifdef DEBUG
#define GDLog( s, ... ) NSLog( @"^_^[%@:(%d)] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define GDLog( s, ... )
#endif
/**
 *  沙盒路径-缓存/Library/XZSP
 */
#define Local_Home_Library_Path ([NSString stringWithFormat:@"%@/Library/XZSP",NSHomeDirectory()])
/**Caches
 *  沙盒路径-表
 */
#define Local_Home_Documents_Path ([NSString stringWithFormat:@"%@/Library",NSHomeDirectory()])

//角度转弧度
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

/**
 *  判断系统版本是否大于9.0
 */
#define iOS_VERSION_9_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES):(NO))

#define iOS_VERSION_8_OR_LATER __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_8_0

#pragma mark - 旋转当前view的方法 Movieviewcontroller
#if 0
if (_isVertical) {
    
    [self.view bringSubviewToFront:_playerView];
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.navigationController.view.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        
        _playerView.frame = CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH);
        [_playerView clearViewUpdate_scaleScreen];
    } completion:^(BOOL finished) {
        _isVertical = NO;
    }];
}else {
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.transform = CGAffineTransformIdentity;
        self.navigationController.view.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        _playerView.frame = PlayerViewFrame(SCREENWIDTH, 200);
        [_playerView clearViewUpdate_scaleScreen];
    } completion:^(BOOL finished) {
        _isVertical = YES;
    }];
}
#endif

#endif /* GD_CustomCenter_h */
