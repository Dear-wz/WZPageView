//
//  WZViewController.m
//  WZPageView
//
//  Created by w__zeng@163.com on 08/24/2018.
//  Copyright (c) 2018 w__zeng@163.com. All rights reserved.
//

#import "WZViewController.h"
#import <WZPageView/WZPageView.h>
@interface WZViewController ()

@end

@implementation WZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* titles = @[@"网游",@"单机",@"手游",@"娱乐",@"颜值",@"新秀",@"推荐",@"网游",@"单机",@"手游",@"娱乐",@"颜值",@"新秀",@"推荐"];
    NSMutableArray* childs = [NSMutableArray array];
    for (NSString* title in titles) {
        UIViewController* child = [UIViewController new];
        child.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
        [childs addObject:child];
    }

    WZTitleViewStyle* style = [[WZTitleViewStyle alloc]init];
    style.scrollEnable = YES;
    style.showSeparator = YES;
    //    style.showCover = YES;
    style.showIndicator = YES;
    style.showMore = YES;

    //    CGRect sframe = CGRectMake(0, 20, self.view.bounds.size.width, 40);
    //    WZTitleView* titleView = [[WZTitleView alloc]initWithFrame:sframe titles:titles style:style];
    //    [self.view addSubview:titleView];

    CGRect sframe2 = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20);
    WZPageView* pageView = [[WZPageView alloc]initWithFrame:sframe2 titles:titles childs:childs rootControl:self style:style];
    [self.view addSubview:pageView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
