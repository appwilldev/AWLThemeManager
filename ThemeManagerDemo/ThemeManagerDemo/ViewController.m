//
//  ViewController.m
//  ThemeManagerDemo
//
//  Created by Neeeo on 14-10-16.
//  Copyright (c) 2014年 AppWill. All rights reserved.
//

#import "ViewController.h"
#import "AWLThemeManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *bundlePath1 = [[NSBundle mainBundle] pathForResource:@"BaseSample" ofType:@"bundle"];
    NSString *bundlePath2 = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"bundle"];
    AWLThemeManager *mgr = [[AWLThemeManager alloc] init];
    [mgr addTheme:bundlePath1];
    mgr.currentTheme = [mgr addTheme:bundlePath2];
    UIImage *img = [mgr imageNamed:@"icon"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    [self.view addSubview:imgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.center = CGPointMake(imgView.center.x, CGRectGetMaxY(imgView.frame) + 30);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [mgr colorForKey:@"Content_Text_Color"];
    titleLabel.font = [mgr fontForKey:@"Content_Font"];
    titleLabel.text = @"Hello, world!";
    [self.view addSubview:titleLabel];
    
    self.view.backgroundColor = [mgr colorForKey:@"View_BG_Color"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
