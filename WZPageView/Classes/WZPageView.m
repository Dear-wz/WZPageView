//
//  WZPageView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZPageView.h"
//#import "WZTitleViewStyle.h"
#import "WZTitleView.h"
#import "WZContainerView.h"
@interface WZPageView()<WZTitleViewDelegate,WZContainerViewDelegate>
@property (nonatomic,strong)NSArray *titles;
@property (nonatomic,strong)NSArray *childs;
@property (nonatomic,strong)UIViewController *rootControl;
@property (nonatomic,strong)WZTitleViewStyle *style;
@property (nonatomic,strong)WZTitleView *titleView;
@property (nonatomic,strong)WZContainerView *contentView;

@end
@implementation WZPageView

-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray<NSString*>*)titles
                      childs:(NSArray<UIViewController*>*)childs
                 rootControl:(UIViewController*)rootControl
                       style:(WZTitleViewStyle*)style{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.childs = childs;
        self.rootControl = rootControl;
        self.style = style;
        
        [self setupSubViews];
    }
    return self;
}
- (void)setupSubViews{
    
    CGRect frame1 = CGRectMake(0, 0, self.bounds.size.width, self.style.titleHeight);
    CGRect frame2 = CGRectMake(0, self.style.titleHeight, self.bounds.size.width, self.bounds.size.height -self.style.titleHeight);

    self.titleView = [[WZTitleView alloc]initWithFrame:frame1 titles:self.titles style:self.style currentIndex:0];
    self.titleView.delegate = self;
    [self addSubview: self.titleView];
    
    self.contentView = [[WZContainerView alloc]initWithFrame:frame2 childs:self.childs rootControl:self.rootControl style:self.style currentIndex:0];
    self.contentView.delegate = self;
    [self insertSubview:self.contentView belowSubview:self.titleView];
}
#pragma mark - public
- (void)updateTitles:(NSArray<NSString*>*)titles{
    [self.titleView updateTitles:titles];
}
//设置标题角标
- (void)setBadge:(NSInteger)badgeValue atIndex:(NSInteger)index{
    [self.titleView setBadge:badgeValue atIndex:index];
}
- (void)clearBadgeAtIndex:(NSInteger)index{
    [self.titleView clearBadgeAtIndex:index];
}
#pragma mark - event
#pragma mark - delegate
#pragma mark ----------- WZTitleViewDelegate
- (void)titleView:(WZTitleView *)titleView targetIndex:(NSInteger)targetIndex{
    [self.contentView setCurrentIndex:targetIndex];
}

#pragma mark ----------- WZContainerViewDelegate
- (void)contentView:(WZContainerView *)contentView sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress{
    [self.titleView setTitleWithSourceIndex:sourceIndex targetIndex:targetIndex progress:progress];
}
- (void)contentView:(WZContainerView *)contentView atIndex:(NSInteger)atIndex{
    [self.titleView setTitleAtIndex:atIndex];
}
#pragma mark - private
#pragma mark - setup
#pragma mark - setter & getter
#pragma mark - networking
@end
