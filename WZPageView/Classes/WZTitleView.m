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

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIView *indicator;
@property (nonatomic,strong)UIView *separator;
@property (nonatomic,strong)UIView *coverView;

@property (strong,nonatomic)UIButton *moreButton;
@property (nonatomic,strong)UIView *moreCoverView;
@property (nonatomic,strong)UICollectionView *showDetail;


@property (nonatomic,strong)NSDictionary *normalColorRGB;
@property (nonatomic,strong)NSDictionary *selectedColorRGB;

@end
@implementation WZTitleView

static NSString * const reuseIdentifier = @"Cell";


#pragma mark - public
-(instancetype)initWithFrame:(CGRect)frame
                      titles:(NSArray<NSString*>*)titles
                       style:(WZTitleViewStyle*)style{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.style = style;
        
        [self setup];
        [self setupSubViews];
    }
    return self;
}
#pragma mark -
-(void)setTitleWithSourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex progress:(CGFloat)progress{
//   //1. 获取对象
    UILabel* labSource = self.titleLabels[sourceIndex];
    UILabel* labTarget = self.titleLabels[targetIndex];
    //2. 颜色获取变化范围
    CGFloat redRange = [[self.selectedColorRGB objectForKey:@"red"] floatValue] -  [[self.normalColorRGB objectForKey:@"red"] floatValue];
    CGFloat greenRange = [[self.selectedColorRGB objectForKey:@"green"] floatValue] -  [[self.normalColorRGB objectForKey:@"green"] floatValue];
    CGFloat blueRange = [[self.selectedColorRGB objectForKey:@"blue"] floatValue] -  [[self.normalColorRGB objectForKey:@"blue"] floatValue];
    labSource.textColor = [UIColor colorWithRed:[[self.selectedColorRGB objectForKey:@"red"] floatValue] - (progress * redRange) green:[[self.selectedColorRGB objectForKey:@"green"] floatValue] - (progress * greenRange) blue:[[self.selectedColorRGB objectForKey:@"blue"] floatValue] - (progress * blueRange) alpha:1.0];
    labTarget.textColor = [UIColor colorWithRed:[[self.normalColorRGB objectForKey:@"red"] floatValue] + (progress * redRange) green:[[self.normalColorRGB objectForKey:@"green"] floatValue] + (progress * greenRange) blue:[[self.normalColorRGB objectForKey:@"blue"] floatValue] + (progress * blueRange) alpha:1.0];
    //3.记录最新索引
    self.currentIndex = targetIndex;
    
    //4. 移动范围
    CGFloat xRange = labTarget.frame.origin.x - labSource.frame.origin.x;
    CGFloat wRange = labTarget.frame.size.width - labSource.frame.size.width;
    if (self.style.showIndicator) {
        CGRect sframe = self.indicator.frame;
        sframe.origin.x = labSource.frame.origin.x + xRange * progress;
        sframe.size.width = labSource.frame.size.width + wRange * progress;
        self.indicator.frame = sframe;
    }
    //5.放大
    if (self.style.needScale) {
        CGFloat scale = (self.style.scaleRange  - 1.0) * progress;
        labSource.transform = CGAffineTransformMakeScale(self.style.scaleRange - scale,self.style.scaleRange - scale);
        labTarget.transform = CGAffineTransformMakeScale(1.0 + scale,1.0 + scale);
    }
    //6.遮罩的滚动
    if (self.style.showCover) {
        CGFloat coverX = self.style.scrollEnable ? (labSource.frame.origin.x - self.style.coverSpace + xRange * progress) : (labSource.frame.origin.x + xRange * progress);
        CGFloat coverW = self.style.scrollEnable ? (labSource.frame.size.width + self.style.coverSpace * 2 + wRange * progress) : (labSource.frame.size.width + wRange * progress);
       
        CGRect sframe = self.coverView.frame;
        sframe.origin.x = coverX;
        sframe.size.width = coverW;
        self.coverView.frame = sframe;
    }
   
}
- (void)contentViewDidEndScroll{
    //    NSLog(@"%s",__func__);
    if (!self.style.scrollEnable) {
        return;
    }
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
#pragma mark -
- (void)updateTitles:(NSArray<NSString*>*)titles{
    NSAssert(titles.count == self.titles.count, @"please make sure the count of titles");
    self.titles = titles;
    for (NSUInteger idx = 0; idx < titles.count; idx++) {
        self.titleLabels[idx].text = titles[idx];
    }
    //更新布局
    [self setupLayoutTitleLabels];
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
    UILabel* currentLabel = (UILabel*)tap.view;
    
    //更新详情控制器的选中
    [self refreshShowDetailSelectedIndex:currentLabel.tag];
    
    // 1. 获取点击的索引
    if (self.currentIndex == currentLabel.tag) {
        NSLog(@"%s重复点击",__func__);
        return;
    }
    //2.0 获取记录的label
    UILabel* oldLabel = self.titleLabels[self.currentIndex];
    
    //3.0 切换颜色
    currentLabel.textColor = self.style.selectedColor;
    oldLabel.textColor= self.style.normalColor;
    
    //4.更新索引
    self.currentIndex = currentLabel.tag;
    
    //5. 代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleView:targetIndex:)]) {
        [self.delegate titleView:self targetIndex:self.currentIndex];
    }
    
    //6.居中显示
    [self contentViewDidEndScroll];
    
    //7 调整下划线
    if (self.style.showIndicator) {
        [UIView animateWithDuration:0.15 animations:^{
            CGRect sframe = self.indicator.frame;
            sframe.origin.x = currentLabel.frame.origin.x;
            sframe.size.width = currentLabel.frame.size.width;
            self.indicator.frame = sframe;
        }];
    }
    //8 调整比例
    if (self.style.needScale) {
        oldLabel.transform = CGAffineTransformIdentity;
        currentLabel.transform = CGAffineTransformMakeScale(self.style.scaleRange,self.style.scaleRange);
    }
    //9 遮罩移动
    if (self.style.showCover) {
        CGFloat coverX = self.style.scrollEnable ? (currentLabel.frame.origin.x - self.style.coverSpace) : (currentLabel.frame.origin.x);
        CGFloat coverW = self.style.scrollEnable ? (currentLabel.frame.size.width + self.style.coverSpace * 2) : (currentLabel.frame.size.width);
        [UIView animateWithDuration:0.15 animations:^{
            CGRect sframe = self.coverView.frame;
            sframe.origin.x = coverX;
            sframe.size.width = coverW;
            self.coverView.frame = sframe;
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
-(NSDictionary*)getRGBWithColor:(UIColor*)color{
    NSAssert(CGColorGetNumberOfComponents(color.CGColor) == 4, @"请使用RGB方式给Title赋值颜色");
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    [dict setValue:@(components[0]) forKey:@"red"];
    [dict setValue:@(components[1]) forKey:@"green"];
    [dict setValue:@(components[2]) forKey:@"blue"];
    [dict setValue:@(components[3]) forKey:@"apha"];
    return dict;
}
- (void)didMoveToSuperview{
    if (self.style.showMore) {
        [self.superview addSubview:self.showDetail];
        [self.superview insertSubview:self.moreCoverView belowSubview:self.showDetail];
        //更新详情控制器的选中
        [self refreshShowDetailSelectedIndex:self.currentIndex];
    }
}
#pragma mark - setup
- (void)setup{
    self.currentIndex = 0;
}
- (void)setupSubViews{
    // 1.添加Scrollview
    [self addSubview:self.scrollView];
    // 2.添加底部分割线
    if (self.style.showSeparator) {
        [self addSubview:self.separator];
    }
    // 3.设置所有的标题Label
    [self setupTitleLables];
    // 4.设置Label的位置
    [self setupLayoutTitleLabels];
    // 5.设置Title指示器
    if (self.style.showIndicator) {
        [self setupIndicator];
    }
    // 6.设置遮盖的View
    if (self.style.showCover) {
        [self setupCover];
    }
    // 7.右边的更多按钮
    if (self.style.showMore) {
        [self addSubview:self.moreButton];
        [self.style updateExpectedHeight:self.titles.count];
        [self.showDetail reloadData];
    }
}
- (void)setupIndicator{
    [self.scrollView addSubview:self.indicator];
    CGRect frame = self.titleLabels.firstObject.frame;
    frame.size.height = self.style.indicatorHeight;
    frame.origin.y = self.bounds.size.height - self.style.indicatorHeight;
    self.indicator.frame = frame;
}
- (void)setupCover{
    [self.scrollView insertSubview:self.coverView atIndex:0];
    CGFloat coverW = self.titleLabels.firstObject.frame.size.width;
    CGFloat coverH = self.style.coverHeight;
    CGFloat coverX = self.titleLabels.firstObject.frame.origin.x;
    CGFloat coverY = (self.bounds.size.height - self.style.coverHeight) * 0.5;
    if (self.style.scrollEnable) {
        coverX -= self.style.coverSpace;
        coverW += (self.style.coverSpace * 2);
    }
    self.coverView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    self.coverView.layer.cornerRadius = self.style.coverRadius;
    self.coverView.layer.masksToBounds = YES;
}
#pragma mark -

-(void)setupTitleLables{
    [self.titles enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel* lab = [[UILabel alloc]init];
        lab.tag = idx;
        lab.text = obj;
        lab.textColor = idx == 0 ? self.style.selectedColor : self.style.normalColor;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = self.style.font;
        lab.userInteractionEnabled = YES;
        [lab addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClick:)]];
        
        [self.titleLabels addObject:lab];
        [self.scrollView addSubview:lab];
    }];
}
-(void)setupLayoutTitleLabels{
   __block CGFloat titleX = 0;
   __block CGFloat titleW = 0;
    CGFloat titleY = 0;
    CGFloat titleH = self.bounds.size.height;
    NSUInteger count = self.titleLabels.count;
    
    for (NSUInteger idx = 0; idx < count; idx++) {
        UILabel* obj = self.titleLabels[idx];
        if (self.style.scrollEnable) {
            CGRect rect = [obj.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:obj.font} context:nil];
            titleW = rect.size.width;
            if (idx == 0) {
                titleX = self.style.titleSpace * 0.5;
            }else{
                UILabel* lab = self.titleLabels[idx - 1];
                titleX = CGRectGetMaxX(lab.frame) + self.style.titleSpace;
            }
        }else{
            titleW = self.bounds.size.width / count;
            titleX = titleW * idx;
        }
        obj.frame = CGRectMake(titleX, titleY, titleW, titleH);
        
        //放大
        if (idx == 0) {
            CGFloat scale = self.style.needScale ? self.style.scaleRange : 1.0;
            obj.transform = CGAffineTransformMakeScale(scale, scale);
        }
        
    }
    if (self.style.scrollEnable) {
        CGFloat labMaxX = CGRectGetMaxX(self.titleLabels.lastObject.frame) + self.style.titleSpace * 0.5;
        CGFloat maxX = labMaxX > self.bounds.size.width ? labMaxX : (self.scrollView.bounds.size.width - (self.style.showMore?self.style.moreWidth:0));
        self.scrollView.contentSize = CGSizeMake(maxX + self.style.titleSpace * 0.5, 0);
    }
}
#pragma mark - setter & getter
- (NSMutableArray<UILabel *> *)titleLabels{
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        CGRect sframe = CGRectMake(0, 0, self.bounds.size.width - (self.style.showMore?self.style.moreWidth:0), self.bounds.size.height);
        _scrollView = [[UIScrollView alloc]initWithFrame:sframe];
//        _scrollView.backgroundColor = [UIColor yellowColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        
    }
    return _scrollView;
}
- (UIView *)indicator{
    if (!_indicator) {
        _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - self.style.indicatorHeight, 0, self.style.indicatorHeight)];
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
- (NSDictionary *)normalColorRGB{
    if (!_normalColorRGB) {
        _normalColorRGB = [self getRGBWithColor:self.style.normalColor];
    }
    return _normalColorRGB;
}
- (NSDictionary *)selectedColorRGB{
    if (!_selectedColorRGB) {
        _selectedColorRGB = [self getRGBWithColor:self.style.selectedColor];
    }
    return _selectedColorRGB;
}
- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(self.bounds.size.width - self.style.moreWidth, 0, self.style.moreWidth, self.bounds.size.height);
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
    [self contentViewDidEndScroll];
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
