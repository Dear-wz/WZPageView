//
//  WZCollectionView.h
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/29.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZCollectionViewLayout.h"
#import "WZTitleView.h"

@class WZCollectionView;
@protocol WZCollectionViewDataSource<NSObject>
@required
- (NSInteger)pageCollectionView:(WZCollectionView *)pageCollectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell*)pageCollectionView:(WZCollectionView *)pageCollectionView collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInPageCollectionView:(WZCollectionView *)pageCollectionView;
@end;

@interface WZCollectionView : UIView
@property (nonatomic ,weak) id <WZCollectionViewDataSource> dataSource;
- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString*>*)titles
                   isTitleTop:(BOOL)isTitleTop
                       layout:(WZCollectionViewLayout*)layout
                        style:(WZTitleViewStyle*)style;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
@end
