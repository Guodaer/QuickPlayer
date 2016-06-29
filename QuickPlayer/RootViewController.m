//
//  RootViewController.m
//  QuickPlayer
//
//  Created by xiaoyu on 16/6/23.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "RootViewController.h"
#import "GD_CustomCenter.h"
#import "MovieViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *playMovie = [UIButton buttonWithType:UIButtonTypeCustom];
    playMovie.frame = CGRectMake(0, 0, 150, 80);
    playMovie.center = CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2);
    [playMovie setTitle:@"Play" forState:UIControlStateNormal];
    [playMovie setBackgroundImage:[self createImageWithColor:XUIColor(0x3b5286, 1)] forState:UIControlStateNormal];
    [playMovie setBackgroundImage:[self createImageWithColor:XUIColor(0x3b5286, 0.75)] forState:UIControlStateHighlighted];
    playMovie.layer.cornerRadius = 4;
    playMovie.clipsToBounds = YES;
    [playMovie addTarget:self action:@selector(playbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playMovie];
    
//    [self shouldAutorotate];
    
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (void)playbtnClick:(UIButton *)sender {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;

    MovieViewController *movieVC = [[MovieViewController alloc] init];
    [self.navigationController pushViewController:movieVC animated:YES];
    
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
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
