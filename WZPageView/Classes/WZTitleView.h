//
//  WZTitleView.h
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WZTitleViewStyle : NSObject
//
@property (nonatomic ,assign) BOOL scrollEnable;//是否是滚动的Title
@property (nonatomic ,strong) UIColor* normalColor;// 普通Title颜色  【默认 黑色】
@property (nonatomic ,strong) UIColor* selectedColor;// 选中Title颜色 【默认 orange】
@property (nonatomic ,strong) UIFont* font;// Title字体    【默认 系统14号】
@property (nonatomic ,assign) CGFloat titleSpace;// 滚动Title的字体间距  【默认 20】
@property (nonatomic ,assign) CGFloat titleHeight;// title的高度  【默认 44】
//
@property (nonatomic ,assign) BOOL showIndicator;// 是否显示Title指示器
@property (nonatomic ,strong) UIColor* indicatorColor;// Title指示器的颜色 【默认 orange】
@property (nonatomic ,assign) CGFloat indicatorHeight;// Title指示器的高度  【默认 2】
//
@property (nonatomic ,assign) BOOL needScale;// 是否进行缩放
@property (nonatomic ,assign) CGFloat scaleRange;   // 【默认 1.2】
//
@property (nonatomic ,assign) BOOL showCover;// 是否显示遮盖
@property (nonatomic ,strong) UIColor* coverBgColor;// 遮盖背景颜色 【默认 lightGrayColor】
@property (nonatomic ,assign) CGFloat coverSpace;// 文字&遮盖间隙    【默认 5】
@property (nonatomic ,assign) CGFloat coverHeight;// 遮盖的高度      【默认 25】
@property (nonatomic ,assign) CGFloat coverRadius;// 设置圆角大小    【默认 15】
//
@property (nonatomic ,assign) BOOL showSeparator;//是否显示底部分割线
@property (nonatomic ,strong) UIColor* separatorColor;//分割线颜色   【默认 lightGrayColor】
//
@property (nonatomic ,assign) BOOL showMore;//是否显示更多按钮
@property (nonatomic ,assign) CGFloat moreWidth; // 更多区域宽度   【默认 60】
@property (nonatomic ,assign) NSUInteger rowCount; // 详情区域列数  【默认 3】
@property (nonatomic ,assign,readonly) CGFloat expectedHeight; // 详情区域高度
@property (nonatomic ,strong) UICollectionViewFlowLayout* layout; // 详情区域布局
@property (nonatomic ,strong) UIColor* moreCoverColor;//详情区域遮罩颜色  [默认 0.6 ,0.6】

//
@property (nonatomic ,strong) UIColor* badgeColor;//角标颜色   【默认 whiltColor】
@property (nonatomic ,strong) UIColor* badgeBackGroundColor; //角标背景色颜色   【默认 redColor】
@property (nonatomic ,strong) UIFont*  badgeFont;// 角标字体    【默认 系统10号】

//更新 =>详情区域高度
- (void)updateExpectedHeight:(NSUInteger)itemCount;

+ (instancetype)shareStyle;
@end



@class WZTitleView;
@protocol WZTitleViewDelegate <NSObject>
- (void)titleView:(WZTitleView *)titleView targetIndex:(NSInteger)targetIndex;
@end

@class WZTitleViewStyle;
@interface WZTitleView : UIView
@property (nonatomic ,weak) id <WZTitleViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray<NSString*>*)titles
                       style:(WZTitleViewStyle*)style;

-(void)setTitleWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress;
-(void)contentViewDidEndScroll;

- (void)updateTitles:(NSArray<NSString*>*)titles;
//设置标题角标
- (void)setBadge:(NSInteger)badgeValue atIndex:(NSInteger)index;
- (void)clearBadgeAtIndex:(NSInteger)index;
@end
