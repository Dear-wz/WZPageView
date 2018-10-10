//
//  WZPageView.h
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZTitleView.h"
@interface WZPageView : UIView
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray<NSString*>*)titles
                      childs:(NSArray<UIViewController*>*)childs
                 rootControl:(UIViewController*)rootControl
                       style:(WZTitleViewStyle*)style;

- (void)updateTitles:(NSArray<NSString*>*)titles;

//设置标题角标
- (void)setBadge:(NSInteger)badgeValue atIndex:(NSInteger)index;
- (void)clearBadgeAtIndex:(NSInteger)index;

@end
