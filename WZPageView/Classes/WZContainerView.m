//
//  WZContainerView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZContainerView.h"
NSString * pageContentIdentifier = @"pageContentIdentifier";
@interface WZContainerView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)NSArray *childs;
@property (nonatomic,strong)UIViewController *rootControl;
@property (nonatomic,strong)UICollectionView *collection;
@property (nonatomic,assign)CGFloat startOffsetX;
@property (nonatomic,assign)BOOL isForbidScrollDelegate;

@end
@implementation WZContainerView

-(instancetype)initWithFrame:(CGRect)frame
                      childs:(NSArray<UIViewController*>*)childs
                 rootControl:(UIViewController*)rootControl{
    if (self = [super initWithFrame:frame]) {
        self.childs = childs;
        self.rootControl = rootControl;
        [self setup];
        [self setupSubViews];
    }
    return self;
}
-(void)setCurrentIndex:(NSUInteger)currentIndex{
    self.isForbidScrollDelegate = YES;
    CGFloat offsetX = currentIndex * self.collection.frame.size.width;
    [self.collection setContentOffset:CGPointMake(offsetX, 0) animated:NO];
}


#pragma mark - life
#pragma mark - event
#pragma mark - delegate
#pragma mark ----------- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.childs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:pageContentIdentifier forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController*child = self.childs[indexPath.row];
    child.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:child.view];
    return cell;
}
#pragma mark ----------- UICollectionViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isForbidScrollDelegate = NO;
    self.startOffsetX = scrollView.contentOffset.x;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 0 点击事件
    if (self.isForbidScrollDelegate) {
        return;
    }
    // 1.定义获取需要的数据
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;
    CGFloat progress = 0.0;
    
    // 2.判断是左滑还是右滑
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    // 左滑
    if (currentOffsetX < self.startOffsetX) {
        // 1.计算progress
        progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW);
        
        // 2.计算sourceIndex
        sourceIndex = floor(currentOffsetX / scrollViewW);
        
        // 3.计算targetIndex
        targetIndex = sourceIndex + 1;
        if (targetIndex >= self.childs.count) {
            targetIndex = self.childs.count - 1;
        }
        
        // 4.如果完全划过去
        if (currentOffsetX - self.startOffsetX == scrollViewW) {
            progress = 1;
            targetIndex = sourceIndex;
        }
    }else{
        // 1.计算progress
        progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW));
        
        // 2.计算targetIndex
        targetIndex = floor(currentOffsetX / scrollViewW);
        
        // 3.计算sourceIndex
        sourceIndex = targetIndex + 1;
        if (sourceIndex >= self.childs.count) {
            sourceIndex = self.childs.count - 1;
        }
    }
   // 3.将progress/sourceIndex/targetIndex传递给titleView
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentView:sourceIndex:targetIndex:progress:)]) {
        [self.delegate contentView:self sourceIndex:sourceIndex targetIndex:targetIndex progress:progress];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewEndScroll:)]) {
            [self.delegate contentViewEndScroll:self];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewEndScroll:)]) {
        [self.delegate contentViewEndScroll:self];
    }
}
#pragma mark - setup
- (void)setup{
    self.isForbidScrollDelegate = NO;
    self.startOffsetX = 0.0;
}
- (void)setupSubViews{
    for (UIViewController* childvc in self.childs) {
        [self.rootControl addChildViewController:childvc];
    }
    [self addSubview:self.collection];
}
#pragma mark - setter & getter
- (UICollectionView *)collection{
    if (!_collection) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = self.bounds.size;
        
        _collection = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collection.scrollsToTop = YES;
        _collection.bounces = NO;
        _collection.showsHorizontalScrollIndicator = NO;
        _collection.backgroundColor = [UIColor clearColor];
        _collection.pagingEnabled = YES;
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.showsHorizontalScrollIndicator = NO;
        [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:pageContentIdentifier];
    }
    return _collection;
}
#pragma mark - networking
@end
