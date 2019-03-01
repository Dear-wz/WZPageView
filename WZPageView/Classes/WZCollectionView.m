//
//  WZCollectionView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/29.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZCollectionView.h"
//#import "WZTitleViewStyle.h"
@interface WZCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)NSArray *titles;
@property (nonatomic,assign)BOOL isTitleTop;
@property (nonatomic,strong)WZTitleViewStyle *style;
@property (nonatomic,strong)WZCollectionViewLayout *layout;
@property (nonatomic,strong)UICollectionView *collection;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,weak)WZTitleView *titleView;
@property (nonatomic,strong)NSIndexPath *currentIndexPath;

@end
@implementation WZCollectionView
#pragma mark - public
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collection registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collection registerNib:nib forCellWithReuseIdentifier:identifier];
}
- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray<NSString*>*)titles
                   isTitleTop:(BOOL)isTitleTop
                       layout:(WZCollectionViewLayout*)layout
                        style:(WZTitleViewStyle*)style{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.isTitleTop = isTitleTop;
        self.layout = layout;
        self.style = style;
        self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self setup];
        [self setupSubViews];
    }
    return self;
}
- (void)setup{
    
}
- (void)setupSubViews{
    CGFloat titleY = self.isTitleTop ? 0 : self.bounds.size.height - self.style.titleHeight;
    WZTitleView* titleView = [[WZTitleView alloc]initWithFrame:CGRectMake(0, titleY, CGRectGetWidth(self.bounds), self.style.titleHeight) titles:self.titles style:self.style currentIndex:0];
    titleView.backgroundColor = [UIColor brownColor];
    [self addSubview: titleView];
    self.titleView = titleView;
    
    CGFloat pageControlH = 20;
    CGFloat pageControlY = self.isTitleTop ?(self.bounds.size.height - pageControlH):(self.bounds.size.height - pageControlH - self.style.titleHeight);
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, pageControlY, self.bounds.size.width, pageControlH)];
    self.pageControl.backgroundColor = [UIColor brownColor];
    [self addSubview:self.pageControl];
    
    CGFloat collectionY = self.isTitleTop ? self.style.titleHeight : 0;
    CGRect  collectionFrame = CGRectMake(0, collectionY, self.bounds.size.width, self.bounds.size.height - self.style.titleHeight - pageControlH);
    self.collection = [[UICollectionView alloc]initWithFrame:collectionFrame collectionViewLayout:self.layout];
    self.collection.backgroundColor = [UIColor yellowColor];
    self.collection.pagingEnabled = YES;
    self.collection.showsVerticalScrollIndicator = NO;    
    self.collection.dataSource = self;
    self.collection.delegate = self;
    [self addSubview:self.collection];
}
#pragma mark - life
#pragma mark - event
#pragma mark - delegate
#pragma mark ----------- WZTitleViewDelegate

#pragma mark ----------- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInPageCollectionView:)]) {
        return [self.dataSource numberOfSectionsInPageCollectionView:self];
    }
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageCollectionView:numberOfItemsInSection:)]) {
        NSInteger itemsCount = [self.dataSource pageCollectionView:self numberOfItemsInSection:section];
        if (section == 0) {
            self.pageControl.numberOfPages = (itemsCount - 1) / (self.layout.rows * self.layout.cols) + 1;
        }
        return itemsCount;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageCollectionView:collectionView:cellForItemAtIndexPath:)]) {
        return [self.dataSource pageCollectionView:self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
     [self contentEndScroll];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
        [self contentEndScroll];
    }
}
#pragma mark - private
-(void)contentEndScroll{
    //1. 取出显示的左上角的第一个cell
    CGPoint point = CGPointMake(self.collection.contentOffset.x + self.layout.sectionInset.left + 1 , self.layout.sectionInset.top + 1);
    NSIndexPath* indexPath = [self.collection indexPathForItemAtPoint:point];
    if (!indexPath) {
        return;
    }
    //2. 根据indexPath设置pageControl
    self.pageControl.currentPage = indexPath.item /(self.layout.rows * self.layout.cols);
    // 3. 判断分组是否发生改变
    if (self.currentIndexPath.section != indexPath.section) {
        NSInteger itemsCount = [self.dataSource pageCollectionView:self numberOfItemsInSection:indexPath.section];
        self.pageControl.numberOfPages = (itemsCount - 1) / (self.layout.rows * self.layout.cols) + 1;
        //设置titleView
        [self.titleView setTitleWithSourceIndex:self.currentIndexPath.section targetIndex:indexPath.section progress:1.0];
        self.currentIndexPath = indexPath;
    }
}
#pragma mark - setup
#pragma mark - setter & getter
#pragma mark - networking
@end
