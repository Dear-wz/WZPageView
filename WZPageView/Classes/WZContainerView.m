//
//  WZContainerView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZContainerView.h"
#import "WZTitleView.h"
@interface WZContainerViewFlowLayout : UICollectionViewFlowLayout
//通过设置offset的值，达到初始化的pageView默认显示某一页的效果，默认显示第一页
@property (nonatomic ,assign) CGFloat offset;
@end
@implementation WZContainerViewFlowLayout

-(void)prepareLayout{
    [super prepareLayout];
    if (self.offset) {
        self.collectionView.contentOffset = CGPointMake(self.offset, 0);
    }else{
        self.collectionView.contentOffset = CGPointZero;
    }
}

@end

NSString * pageContentIdentifier = @"pageContentIdentifier";

@interface WZContainerView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)NSArray *childs;
@property (nonatomic,strong)UIViewController *rootControl;
@property (nonatomic,strong)UICollectionView *collection;
@property (nonatomic,assign) NSUInteger startIndex;
@property (nonatomic,assign)CGFloat startOffsetX;
@property (nonatomic,assign)BOOL isForbidScrollDelegate;
@property (nonatomic,strong) WZTitleViewStyle *style;
@end
@implementation WZContainerView

-(instancetype)initWithFrame:(CGRect)frame
                      childs:(NSArray<UIViewController*>*)childs
                 rootControl:(UIViewController*)rootControl
                       style:(WZTitleViewStyle*)style
                currentIndex:(NSUInteger)currentIndex{
    if (self = [super initWithFrame:frame]) {
        self.childs = childs;
        self.rootControl = rootControl;
        self.style = style;
        self.startIndex = currentIndex;
        [self setupSubViews];
    }
    return self;
}
-(void)setCurrentIndex:(NSUInteger)currentIndex{
    self.isForbidScrollDelegate = YES;
    if (currentIndex > self.childs.count - 1) {
        return;
    }
    NSIndexPath*indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
    [self.collection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.collection.frame = self.bounds;
    WZContainerViewFlowLayout* layout = (WZContainerViewFlowLayout*)self.collection.collectionViewLayout;
    layout.itemSize = self.bounds.size;
    layout.offset = self.startIndex * self.bounds.size.width;
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
    [self updateUI:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self collectionViewDidEndScroll:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self collectionViewDidEndScroll:scrollView];
}
- (void)collectionViewDidEndScroll:(UIScrollView *)scrollView{
    NSUInteger index =  (scrollView.contentOffset.x / scrollView.bounds.size.width);
//    UIViewController* child = self.childs[index];
//    if ([child conformsToProtocol:@protocol(LWJPageViewProtocol)] ) {
//        if ([child respondsToSelector:@selector(contentViewDidEndScroll)]) {
//            [child performSelector:@selector(contentViewDidEndScroll)];
//        }
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentView:atIndex:)]) {
        [self.delegate contentView:self atIndex:index];
    }
}

- (void)updateUI:(UIScrollView *)scrollView{
    if (self.isForbidScrollDelegate) {
        return;
    }
    CGFloat progress = 0;
    NSUInteger targetIndex = 0;
    NSUInteger sourceIndex = 0;
    
    progress = fmod(scrollView.contentOffset.x, scrollView.bounds.size.width) / scrollView.bounds.size.width;
    if (progress == 0) {
        return;
    }
    // + 0.01 确保不会被整除
    NSUInteger index =  (floor(scrollView.contentOffset.x / (scrollView.bounds.size.width + 0.01)));
    
    if (scrollView.contentOffset.x > self.startOffsetX) { // 左滑动
        sourceIndex = index;
        targetIndex = index + 1;
        if (targetIndex > self.childs.count - 1) {
            return;
        }
    }else{
        sourceIndex = index + 1;
        targetIndex = index;
        progress = 1 - progress;
        if (targetIndex < 0) {
            return;
        }
    }
    if (progress > 0.998){
        progress = 1;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentView:sourceIndex:targetIndex:progress:)]) {
        [self.delegate contentView:self sourceIndex:sourceIndex targetIndex:targetIndex progress:progress];
    }
    
}
#pragma mark - setup
- (void)setupSubViews{
    for (UIViewController* childvc in self.childs) {
        [self.rootControl addChildViewController:childvc];
    }
    self.collection = ({
        WZContainerViewFlowLayout* layout = [[WZContainerViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView* collection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        collection.showsHorizontalScrollIndicator = NO;
        collection.pagingEnabled = YES;
        collection.scrollsToTop = NO;
        collection.dataSource = self;
        collection.delegate = self;
        collection.bounces = NO;
        if (@available(iOS 10,*)) {
            collection.prefetchingEnabled = NO;
        }
        [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:pageContentIdentifier];
        collection;
    });
    
    [self addSubview:self.collection];
    self.collection.backgroundColor = self.style.contentViewBackgroundColor;
    self.collection.scrollEnabled = self.style.isContentScrollEnable;
}
@end
