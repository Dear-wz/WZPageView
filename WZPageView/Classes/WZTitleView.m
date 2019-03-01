//
//  WZTitleView.m
//  WZPageView
//
//  Created by 立刻科技 on 2018/6/28.
//  Copyright © 2018年 立刻科技. All rights reserved.
//

#import "WZTitleView.h"
//#import "WZTitleDetialViewController.h"
@implementation WZTitleViewStyle

+ (instancetype)shareStyle{
    return [self init];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        /// 是否是滚动的Title
        self.scrollEnable = NO;
        /// 普通Title颜色
        self.normalColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        /// 选中Title颜色
        self.selectedColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
        /// Title字体大小
        self.font = [UIFont systemFontOfSize:14.f];
        /// 滚动Title的字体间距
        self.titleSpace =  20;
        /// title的高度
        self.titleHeight =  44;
        _titleViewBackgroundColor = [UIColor whiteColor];
        
        /// 是否显示Title指示器
        self.showIndicator =  NO;
        /// Title指示器的颜色
        self.indicatorColor = [UIColor orangeColor];
        /// Title指示器的高度
        self.indicatorHeight =  2;
        
        /// 是否进行缩放
        self.needScale =  NO;
        self.scaleRange =  1.2;
        
        /// 是否显示遮盖
        self.showCover =  NO;
        /// 遮盖背景颜色
        self.coverBgColor = [UIColor lightGrayColor];
        /// 文字&遮盖间隙
        self.coverSpace =  5;
        /// 遮盖的高度
        self.coverHeight =  25;
        /// 设置圆角大小
        self.coverRadius =  12;
        
        self.showSeparator = NO;
        self.separatorColor = [UIColor lightGrayColor];
        
        _contentScrollEnable = NO;
        _contentViewBackgroundColor = [UIColor whiteColor];
        
        self.showMore = NO;
        self.moreWidth = 60.f;
        
        self.rowCount = 4;
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        
        CGFloat kMargin = 6;
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - kMargin * (self.rowCount + 1)) / self.rowCount;
        CGFloat height = 30.f;
        
        self.layout.itemSize = CGSizeMake(width, height);
        self.layout.minimumLineSpacing = kMargin;
        self.layout.minimumInteritemSpacing = kMargin;
        
        
        self.moreCoverColor = [UIColor colorWithWhite:0.6 alpha:0.6];
        
        self.badgeFont = [UIFont systemFontOfSize:10.f];
        self.badgeColor = [UIColor whiteColor];
        self.badgeBackGroundColor = [UIColor redColor];
    }
    return self;
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    [self checkRGBAColor:normalColor];
}
- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    [self checkRGBAColor:selectedColor];
}
-(void)checkRGBAColor:(UIColor*)color{
    if (CGColorGetNumberOfComponents(color.CGColor) != 4) {
        NSLog(@"建议使用RGBA方式创建颜色,否则没有字体颜色渐变效果");
    }
}
//更新 =>详情区域高度
- (void)updateExpectedHeight:(NSUInteger)itemCount{
    NSInteger rows = (itemCount + (_rowCount - 1)) / _rowCount;
    _expectedHeight = rows * (self.layout.itemSize.height + 6);
}
@end


@interface WZTitleCell: UICollectionViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *selectedColor;
@end

@implementation WZTitleCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.normalColor = [UIColor blackColor];
        self.selectedColor = [UIColor orangeColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:self.contentView.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.titleLabel.textColor = selected ? self.selectedColor:self.normalColor;
    [self layoutIfNeeded];
}

@end



@interface WZTitleView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)NSArray *titles;
@property (nonatomic,strong)WZTitleViewStyle *style;
@property (nonatomic,assign)NSUInteger currentIndex;

@property (nonatomic,strong)NSMutableArray<UILabel*> *titleLabels;
@property (nonatomic,strong)NSMutableArray<UILabel*> *badgeLabels;

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIView *indicator;
@property (nonatomic,strong)UIView *separator;
@property (nonatomic,strong)UIView *coverView;

@property (strong,nonatomic)UIButton *moreButton;
@property (nonatomic,strong)UIView *moreCoverView;
@property (nonatomic,strong)UICollectionView *showDetail;


@property (nonatomic ,strong) CIColor *normalColor;
@property (nonatomic ,strong) CIColor *selectColor;
@property (nonatomic ,assign) CGFloat deltaColorR;
@property (nonatomic ,assign) CGFloat deltaColorG;
@property (nonatomic ,assign) CGFloat deltaColorB;

@end
@implementation WZTitleView

static NSString * const reuseIdentifier = @"Cell";


#pragma mark - public
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray<NSString*>*)titles
                       style:(WZTitleViewStyle*)style
                currentIndex:(NSUInteger)currentIndex{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.style = style;
        self.currentIndex = currentIndex;
        [self setupSubViews];
    }
    return self;
}
//设置标题角标
- (void)setBadge:(NSInteger)badgeValue atIndex:(NSInteger)index{
    if (index > self.titles.count || index < 0) {
        return;
    }
    UILabel* labBadge = [self.scrollView viewWithTag: 2333 + index];
    if (!labBadge) {
        [self createBadgeLabel:index];
        [self setBadge:badgeValue atIndex:index];
        return;
    }else{
        CGPoint point = [self getlabelTextRightTop:index];
        labBadge.text = [@(badgeValue) stringValue];
        CGFloat cornerRadius = 7.5;
        labBadge.layer.cornerRadius = cornerRadius;
        labBadge.frame = CGRectMake(point.x, point.y - cornerRadius, 2 * cornerRadius, 2 * cornerRadius);
    }
}
- (void)clearBadgeAtIndex:(NSInteger)index{
    UILabel* lab = [self.scrollView viewWithTag: 2333 + index];
    [lab removeFromSuperview];
}
#pragma mark -
-(void)setTitleWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress{
//   //1. 获取对象
    if (sourceIndex > self.titleLabels.count - 1 || sourceIndex < 0) {
        return;
    }
    if (targetIndex > self.titleLabels.count - 1 || targetIndex < 0) {
        return;
    }
    UILabel* sourceLabel = self.titleLabels[sourceIndex];
    UILabel* targetLabel = self.titleLabels[targetIndex];
    //2. 颜色获取变化范围
    sourceLabel.textColor = [UIColor colorWithRed:self.selectColor.red - progress * self.deltaColorR green:self.selectColor.green - progress * self.deltaColorG blue:self.selectColor.blue - progress * self.deltaColorB alpha:1.0];
    targetLabel.textColor = [UIColor colorWithRed:self.normalColor.red + progress * self.deltaColorR green:self.normalColor.green + progress * self.deltaColorG blue:self.normalColor.blue + progress * self.deltaColorB alpha:1.0];
    if (self.style.needScale) {
        CGFloat deltaScale = self.style.scaleRange - 1.0;
        sourceLabel.transform = CGAffineTransformMakeScale(self.style.scaleRange - progress * deltaScale, self.style.scaleRange - progress * deltaScale);
        targetLabel.transform = CGAffineTransformMakeScale(1.0 + progress * deltaScale, 1.0 + progress * deltaScale);
    }
    
    if (self.style.showIndicator) {
        CGFloat deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x;
        CGFloat deltaW = targetLabel.frame.size.width - sourceLabel.frame.size.width;
        CGRect frame = self.indicator.frame;
        frame.origin.x = sourceLabel.frame.origin.x + progress * deltaX;
        frame.size.width = sourceLabel.frame.size.width + progress * deltaW;
        self.indicator.frame = frame;
    }
    
    if (self.style.showCover) {
        CGFloat deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x;
        CGFloat deltaW = targetLabel.frame.size.width - sourceLabel.frame.size.width;
        
        CGRect frame = self.coverView.frame;
        
        frame.size.width = self.style.scrollEnable ? (sourceLabel.frame.size.width + 2 * self.style.coverSpace + deltaW * progress) : (sourceLabel.frame.size.width + deltaW * progress);
        frame.origin.x = self.style.scrollEnable ? (sourceLabel.frame.origin.x - self.style.coverSpace + deltaX * progress) : (sourceLabel.frame.origin.x + deltaX * progress);
        self.coverView.frame = frame;
    }
   
}
-(void)setTitleAtIndex:(NSInteger)atIndex{
    self.currentIndex = atIndex;
    UILabel* targetLabel = self.titleLabels[self.currentIndex];
    [self adjustLabelPosition:targetLabel];
    [self adjustFixUI:targetLabel];
}

- (void)contentViewDidEndScroll{
    if (!self.style.scrollEnable) {
        return;
    }
    NSLog(@"%s",__func__);
    //1 获取目标label
    UILabel* targetLabel = self.titleLabels[self.currentIndex];
    
    //2. 计算偏移量
    CGFloat offsetX = targetLabel.center.x - self.scrollView.bounds.size.width * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width - self.style.titleSpace * 0.5;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    //3.0 滚动
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    //4.0更新详情控制器的选中
    [self refreshShowDetailSelectedIndex:self.currentIndex];
}

- (void)adjustLabelPosition:(UILabel*)targetLabel{
    if (!self.style.scrollEnable) {
        return;
    }
    CGFloat offsetX = targetLabel.center.x - self.bounds.size.width * 0.5;
    CGFloat availableMaxX  =  self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    
    offsetX = offsetX > availableMaxX ? availableMaxX : offsetX;
    offsetX = offsetX < 0 ? 0 : offsetX;
    
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}
- (void)adjustFixUI:(UILabel*)targetLabel{
    [UIView animateWithDuration:0.05 animations:^{
        targetLabel.textColor = self.style.selectedColor;
        if (self.style.needScale) {
            targetLabel.transform = CGAffineTransformMakeScale(self.style.scaleRange, self.style.scaleRange);
        }
        if (self.style.showIndicator) {
            CGRect frame = self.indicator.frame;
            frame.origin.x = targetLabel.frame.origin.x;
            frame.size.width = targetLabel.frame.size.width;
            self.indicator.frame = frame;
        }
        if (self.style.showCover) {
            CGFloat coverX = targetLabel.frame.origin.x - (self.style.scrollEnable?self.style.coverSpace:0);
            CGFloat coverW = targetLabel.frame.size.width + (self.style.scrollEnable?2 * self.style.coverSpace:0);
            CGRect frame = self.coverView.frame;
            frame.origin.x = coverX;
            frame.size.width = coverW;
            self.coverView.frame = frame;
        }
    }];
}

#pragma mark -
- (void)updateTitles:(NSArray<NSString*>*)titles{
    NSAssert(titles.count == self.titles.count, @"please make sure the count of titles");
    self.titles = titles;
    for (NSUInteger idx = 0; idx < titles.count; idx++) {
        self.titleLabels[idx].text = titles[idx];
    }
    //更新布局
//    [self setupLayoutTitleLabels];
    [self layoutIfNeeded];
}
#pragma mark - event
- (void)showOrHide:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self showDetailPane];
    }else {
        [self hideDetailPane];
    }
}
- (void)showDetailPane{
//    self.moreButton.selected = YES;
//    self.showDetailVC.collectionView.hidden = NO;
    self.showDetail.hidden = NO;
    self.moreCoverView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect sframe1 = self.showDetail.frame;
        sframe1.size.height = self.style.expectedHeight;
        self.showDetail.frame = sframe1;
        
        CGRect sframe2 = self.moreCoverView.frame;
        sframe2.size.height = [UIScreen mainScreen].bounds.size.height;
        self.moreCoverView.frame = sframe2;
    }];
}
- (void)hideDetailPane{
//    self.moreButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect sframe1 = self.showDetail.frame;
        sframe1.size.height = 0;
        self.showDetail.frame = sframe1;
        
        CGRect sframe2 = self.moreCoverView.frame;
        sframe2.size.height = 0;
        self.moreCoverView.frame = sframe2;
        
    } completion:^(BOOL finished) {
        self.moreCoverView.hidden = YES;
        self.showDetail.hidden = YES;
    }];
}

- (void)titleClick:(UITapGestureRecognizer*)tap{
    //0. 获取当前label
    UILabel* targetLabel = (UILabel*)tap.view;
    //更新详情控制器的选中
    [self refreshShowDetailSelectedIndex:targetLabel.tag];
    
    // 1. 获取点击的索引
    if (self.currentIndex == targetLabel.tag) {
        NSLog(@"%s重复点击",__func__);
        return;
    }
    UILabel* sourceLabel = self.titleLabels[self.currentIndex];
    sourceLabel.textColor = self.style.normalColor;
    targetLabel.textColor = self.style.selectedColor;
    
    self.currentIndex = targetLabel.tag;
    [self adjustLabelPosition:targetLabel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleView:targetIndex:)]) {
        [self.delegate titleView:self targetIndex:self.currentIndex];
    }
    
    if (self.style.needScale) {
        [UIView animateWithDuration:0.25 animations:^{
            sourceLabel.transform = CGAffineTransformIdentity;
            targetLabel.transform = CGAffineTransformMakeScale(self.style.scaleRange, self.style.scaleRange);
        }];
    }
    
    if (self.style.showIndicator) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.indicator.frame;
            frame.origin.x = targetLabel.frame.origin.x;
            frame.size.width = targetLabel.frame.size.width;
            self.indicator.frame = frame;
        }];
    }
    
    if (self.style.showCover) {
        CGFloat coverX = self.style.scrollEnable ? (targetLabel.frame.origin.x - self.style.coverSpace) : targetLabel.frame.origin.x;
        CGFloat coverW = self.style.scrollEnable ? (targetLabel.frame.size.width + self.style.coverSpace * 2) : targetLabel.frame.size.width;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.coverView.frame;
            frame.origin.x = coverX;
            frame.size.width = coverW;
            self.coverView.frame = frame;
        }];
    }
  
}
- (void)refreshShowDetailSelectedIndex:(NSUInteger)target{
    if (self.style.showMore) {
//        NSLog(@"showDetailSelectedIndex:%ld",target);
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:target inSection:0];
        [self.showDetail selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [self hideDetailPane];
    }
}
#pragma mark - private
- (void)didMoveToSuperview{
    if (self.style.showMore) {
        [self.superview addSubview:self.showDetail];
        [self.superview insertSubview:self.moreCoverView belowSubview:self.showDetail];
        //更新详情控制器的选中
        [self refreshShowDetailSelectedIndex:self.currentIndex];
    }
}
- (CGPoint)getlabelTextRightTop:(NSUInteger)index{
    UILabel* lab = self.titleLabels[index];
    CGRect rect = [lab.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lab.font} context:nil];
    CGFloat x = CGRectGetMaxX(lab.frame) - 0.5 * (CGRectGetWidth(lab.frame) - rect.size.width);
    CGFloat y = 0.5 * (CGRectGetHeight(lab.frame) - rect.size.height);
    return CGPointMake(x, y);
}
#pragma mark - setup
- (void)createBadgeLabel:(NSUInteger)index{
    UILabel* badge = [[UILabel alloc]init];
    badge.tag = index + 2333;
    badge.textAlignment = NSTextAlignmentCenter;
    badge.font = self.style.badgeFont;
    badge.textColor = self.style.badgeColor;
    badge.backgroundColor = self.style.badgeBackGroundColor;
    badge.layer.masksToBounds = YES;
    [self.scrollView insertSubview:badge belowSubview:self.titleLabels[index]];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect sframe = CGRectMake(0, 0, self.bounds.size.width - (self.style.showMore?self.style.moreWidth:0), self.bounds.size.height);
    self.scrollView.frame = sframe;
    
    [self setupLabelsLayout];
    [self setupBottomLineLayout];
    [self setupCoverViewLayout];
    [self setupMoreViewLayout];
}
- (void)setupLabelsLayout{
    CGFloat labelH = self.frame.size.height;
    CGFloat labelY = 0;
    CGFloat labelW = 0;
    CGFloat labelX = 0;
    NSUInteger count = self.titles.count;
    for (NSUInteger i = 0; i < count; i++) {
        UILabel*  titleLabel = self.titleLabels[i];
        if (self.style.scrollEnable) {
            labelW = [self.titles[i] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: titleLabel.font} context:nil].size.width;
            labelX = i == 0 ? self.style.titleSpace * 0.5 : (CGRectGetMaxX(self.titleLabels[i-1].frame) + self.style.titleSpace);
        }else{
            labelW = self.bounds.size.width / count;
            labelX = labelW * i;
        }
        titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    }
    if (self.style.needScale) {
        self.titleLabels.firstObject.transform = CGAffineTransformMakeScale(self.style.scaleRange, self.style.scaleRange);
    }
    
    if (self.style.scrollEnable) {
        CGSize size = self.scrollView.contentSize;
        CGFloat maxX = CGRectGetMaxX(self.titleLabels.lastObject.frame) + self.style.titleSpace * 0.5;
        size.width = MAX(size.width, maxX);
        self.scrollView.contentSize = size;
    }
}
- (void)setupBottomLineLayout{
    if (self.titleLabels.count - 1 >= self.currentIndex) {
        UILabel *label = self.titleLabels[self.currentIndex];
        CGRect frame = self.indicator.frame;
        frame.origin.x = label.frame.origin.x;
        frame.size.width = label.frame.size.width;
        frame.size.height = self.style.indicatorHeight;
        frame.origin.y = self.bounds.size.height - self.style.indicatorHeight;
        self.indicator.frame = frame;
    }
}
- (void)setupCoverViewLayout{
    if (self.titleLabels.count - 1 >= self.currentIndex) {
        UILabel *label = self.titleLabels[self.currentIndex];
        CGFloat coverW = label.bounds.size.width;
        CGFloat coverH = self.style.coverHeight;
        CGFloat coverX = label.frame.origin.x;
        CGFloat coverY = label.center.y - coverH * 0.5;
        if (self.style.scrollEnable) {
            coverX -= self.style.coverSpace;
            coverW += 2 * self.style.coverSpace;
        }
        self.coverView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    }
}
- (void)setupMoreViewLayout{
    self.moreButton.frame = CGRectMake(self.scrollView.bounds.size.width, 0, self.style.moreWidth, self.bounds.size.height);
}
#pragma mark - setup
- (void)setupSubViews{
    [self addSubview:self.scrollView];
    
    self.scrollView.backgroundColor = self.style.titleViewBackgroundColor;
    [self setupTitleLabels];
    [self setupBottomLine];
    [self setupCoverView];
    [self setupMoreView];
    
}
- (void)setupTitleLabels{
    for (NSUInteger i = 0; i < self.titles.count; i++) {
        UILabel* lab = [[UILabel alloc]init];
        
        lab.tag = i;
        lab.text = self.titles[i];
        lab.textColor = i == self.currentIndex ? self.style.selectedColor : self.style.normalColor;
        lab.textAlignment = NSTextAlignmentCenter;
        
        [self.scrollView addSubview:lab];
        [self.titleLabels addObject:lab];
        
        lab.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClick:)];
        [lab addGestureRecognizer:tap];
    }
}
- (void)setupBottomLine{
    if (!self.style.showIndicator) {
        return;
    }
    [self.scrollView addSubview:self.indicator];
}
- (void)setupCoverView{
    if (!self.style.showCover) {
        return;
    }
    [self.scrollView insertSubview:self.coverView atIndex:0];
    self.coverView.layer.cornerRadius = self.style.coverRadius;
    self.coverView.layer.masksToBounds = YES;
}
- (void)setupMoreView{
    if (self.style.showMore) {
        [self addSubview:self.moreButton];
        [self.style updateExpectedHeight:self.titles.count];
        [self.showDetail reloadData];
    }
}
#pragma mark - setter & getter
- (CIColor *)normalColor{
    if (!_normalColor) {
        CGFloat r = 0,g = 0,b = 0;
        [self.style.normalColor getRed:&r green:&g blue:&b alpha:nil];
        _normalColor = [CIColor colorWithRed:r green:g blue:b];
    }
    return _normalColor;
}
- (CIColor *)selectColor{
    if (!_selectColor) {
        CGFloat r = 0,g = 0,b = 0;
        [self.style.selectedColor getRed:&r green:&g blue:&b alpha:nil];
        _selectColor = [CIColor colorWithRed:r green:g blue:b];
    }
    return _selectColor;
}
- (CGFloat)deltaColorR{
    if (!_deltaColorR) {
        _deltaColorR = self.selectColor.red - self.normalColor.red;
    }
    return _deltaColorR;
}
- (CGFloat)deltaColorG{
    if (!_deltaColorG) {
        _deltaColorG = self.selectColor.green - self.normalColor.green;
    }
    return _deltaColorG;
}
- (CGFloat)deltaColorB{
    if (!_deltaColorB) {
        _deltaColorB = self.selectColor.blue - self.normalColor.blue;
    }
    return _deltaColorB;
}
- (NSMutableArray<UILabel *> *)titleLabels{
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}
- (NSMutableArray<UILabel *> *)badgeLabels{
    if (!_badgeLabels) {
        _badgeLabels = [NSMutableArray array];
    }
    return _badgeLabels;
}
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}
- (UIView *)indicator{
    if (!_indicator) {
        _indicator = [[UIView alloc]initWithFrame:CGRectZero];
        _indicator.backgroundColor = self.style.indicatorColor;
    }
    return _indicator;
}
- (UIView *)separator{
    if (!_separator) {
        CGFloat h = 0.5;
        _separator = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - h, self.bounds.size.width, h)];
        _separator.backgroundColor = self.style.separatorColor;
    }
    return _separator;
}
-(UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]init];
        _coverView.backgroundColor = self.style.coverBgColor;
        _coverView.alpha = 0.7;
    }
    return _coverView;
}
- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
        [_moreButton setTitleColor:self.style.normalColor forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:self.style.font];
        [_moreButton addTarget:self action:@selector(showOrHide:) forControlEvents:UIControlEventTouchUpInside];
        //分割线
        UIView* separator = [[UIView alloc]initWithFrame:CGRectMake(0, 5, 0.5, self.bounds.size.height - 10)];
        separator.backgroundColor = self.style.separatorColor;
        [_moreButton addSubview:separator];
    }
    return _moreButton;
}
- (UICollectionView *)showDetail{
    if (!_showDetail) {
        _showDetail = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame), self.bounds.size.width, 0) collectionViewLayout:self.style.layout];
        _showDetail.backgroundColor = [UIColor whiteColor];
        _showDetail.delegate = self;
        _showDetail.dataSource = self;
        [_showDetail registerClass:[WZTitleCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return _showDetail;
}
- (UIView *)moreCoverView{
    if (!_moreCoverView) {
        _moreCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame), self.bounds.size.width, 0)];
        _moreCoverView.backgroundColor = self.style.moreCoverColor;
        [_moreCoverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailPane)]];
    }
    return _moreCoverView;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self setTitleWithSourceIndex:self.currentIndex targetIndex:indexPath.item progress:1.0];
//    [self setTitleAtIndex:indexPath.item];
//    [self contentViewDidEndScroll];
    [self hideDetailPane];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WZTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = self.titles[indexPath.item];
    cell.titleLabel.font = self.style.font;
    cell.selectedColor = self.style.selectedColor;
    cell.normalColor = self.style.normalColor;
    return cell;
}

@end
