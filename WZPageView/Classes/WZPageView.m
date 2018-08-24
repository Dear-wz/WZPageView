//
//  WZPageView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZPageView.h"
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
    self.titleView = [[WZTitleView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.style.titleHeight) titles:self.titles style:self.style];
    self.titleView.delegate = self;
    [self addSubview: self.titleView];
    
    self.contentView = [[WZContainerView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.titleView.bounds)) childs:self.childs rootControl:self.rootControl];
    self.contentView.delegate = self;
    [self insertSubview:self.contentView belowSubview:self.titleView];
}
#pragma mark - public
- (void)updateTitles:(NSArray<NSString*>*)titles{
    [self.titleView updateTitles:titles];
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

- (void)contentViewEndScroll:(WZContainerView *)contentView{
    [self.titleView contentViewDidEndScroll];
}
#pragma mark - private
#pragma mark - setup
#pragma mark - setter & getter
#pragma mark - networking
@end
