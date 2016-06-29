//
//  GDAVPlayerTimeTool.m
//  QuickPlayer
//
//  Created by xiaoyu on 16/6/29.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "GDAVPlayerTimeTool.h"

@implementation GDAVPlayerTimeTool

#pragma mark - 根据秒数计算时间
NSString * calculateTimeWithTimeFormatter(long long timeSecond){
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}

@end
