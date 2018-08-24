//
//  WZContainerView.h
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZContainerView;
@protocol WZContainerViewDelegate <NSObject>
- (void)contentView:(WZContainerView *)contentView sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress;
@optional
- (void)contentViewEndScroll:(WZContainerView *)contentView;
@end
@class WZTitleViewStyle;
@interface WZContainerView : UIView
@property (nonatomic ,weak) id <WZContainerViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame
                      childs:(NSArray<UIViewController*>*)childs
                 rootControl:(UIViewController*)rootControl;
-(void)setCurrentIndex:(NSUInteger)currentIndex;
@end
