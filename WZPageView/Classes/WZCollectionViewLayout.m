//
//  WZCollectionViewLayout.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/29.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZCollectionViewLayout.h"
@interface WZCollectionViewLayout()
@property (nonatomic ,strong) NSMutableArray<UICollectionViewLayoutAttributes*>*attributes;
@property (nonatomic ,assign) CGFloat maxWidth;
@end

@implementation WZCollectionViewLayout
- (instancetype)init{
    if (self = [super init]) {
        self.rows = 3;
        self.cols = 6;
        self.maxWidth = 0;
        self.attributes = [NSMutableArray array];
    }
    return self;
}


-(void)prepareLayout{
    [super prepareLayout];
    
    //1. 计算item的尺寸
    CGFloat itemW = (self.collectionView.bounds.size.width - (self.sectionInset.left + self.sectionInset.right) - (self.cols - 1) * self.minimumInteritemSpacing)/self.cols;
    CGFloat itemH = (self.collectionView.bounds.size.height - (self.sectionInset.top + self.sectionInset.bottom) - (self.rows - 1) * self.minimumInteritemSpacing)/self.rows;
    //2.0 获取组
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    //3.0 获取item
    NSUInteger previousAllPages = 0;
    for (NSUInteger section = 0; section < sectionCount; section++) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSUInteger row = 0; row < itemCount; row++) {
            //3.1 创建Cell的IndexPath
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            //3.2 创建cell的布局
            UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            //3.3 计算当前cell所在页
            NSUInteger page = row / (self.rows * self.cols);
            NSUInteger pageIndex = row % (self.rows * self.cols);;
            //3.4 设置frame
            CGFloat itemX = self.collectionView.bounds.size.width *(previousAllPages + page) + self.sectionInset.left + (self.minimumInteritemSpacing + itemW) * (pageIndex % self.cols);
            CGFloat itemY = self.sectionInset.top + (self.minimumLineSpacing + itemH) * (pageIndex / self.cols);
            attrs.frame = CGRectMake(itemX, itemY, itemW, itemH);
            //3.5 保存属性
            [self.attributes addObject:attrs];
        }
        previousAllPages += (itemCount - 1) / (self.rows * self.cols) + 1;
     }
    //4. 最大宽度
    self.maxWidth = self.collectionView.bounds.size.width * previousAllPages;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.attributes;
}
- (CGSize)collectionViewContentSize{
    return CGSizeMake(self.maxWidth, 0);
}
@end
