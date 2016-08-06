//
//  UIScrollView+TTExtention.m
//  TT3DScrollView
//
//  Created by hehe.Mr on 16/8/3.
//  Copyright © 2016年 Vinson. All rights reserved.
//

#import "UIScrollView+TTExtention.h"

#define screen_width		[UIScreen mainScreen].bounds.size.width
#define self_height			self.frame.size.height
#define self_width			self.frame.size.width
#define pageControlHeight   20

static const CGFloat	scaleFloat = 0.25;
NSMutableArray			*subviewsArray;
UIPageControl			*pageControl = nil;
NSTimer					*timer = nil;
NSInteger				numPage = 0;
BOOL					isShowInfiniteLoop = NO;
BOOL					isShow3DRotate = NO;
BOOL					isShowTimer = NO;

@implementation UIScrollView (TTExtention)
#pragma mark - 初始化
- (void)setup
{
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.contentSize = CGSizeMake(screen_width * self.subviews.count, 0);
	self.pagingEnabled = YES;
	self.delegate = self;
	
	subviewsArray = [self.subviews mutableCopy];
	[self removeAllObservationInfo];
	// 监听contentOffset属性
	[self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)setSubviewsFrame
{
	[self setup];
	[self.subviews enumerateObjectsUsingBlock:^(__kindof UIImageView * _Nonnull imageView, NSUInteger index, BOOL * _Nonnull stop) {
		CGRect frame = (CGRect){CGPointZero, CGSizeMake(self_width, CGRectGetHeight(self.frame))};
		frame.origin.x = index * self_width;
		imageView.frame = frame;
	}];
}
#pragma mark - 外部添加的功能
- (void)addSubviewsWithImageName:(NSString *)imageName pageCount:(NSInteger)pageCount
{
	for (NSInteger i = 0; i < pageCount; i++) {
		UIImageView *imageView = [[UIImageView alloc] init];
		imageView.image = [UIImage imageNamed:[imageName stringByAppendingString:[@(i) stringValue]]];
		[self addSubview:imageView];
	}
	[self setSubviewsFrame];
}
- (void)addPageControl
{
	pageControl = [[UIPageControl alloc] init];
	CGFloat originY = self.frame.size.height + self.frame.origin.y - pageControlHeight - 5;
	pageControl.frame = CGRectMake(0, originY, screen_width, pageControlHeight);
	pageControl.numberOfPages = self.subviews.count - (isShowInfiniteLoop ? 2 : 0);
	[self.superview addSubview:pageControl];
}

- (void)addInfiniteLoop
{
	self.contentSize = CGSizeMake(self_width * subviewsArray.count, 0);
	self.contentOffset = CGPointMake(self_width, 0);
	isShowInfiniteLoop = YES;
}

- (void)add3DRotate
{
	isShow3DRotate = YES;
}
- (void)addTimer
{
	isShowTimer = YES;
	if (!timer) {
		timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
		[timer fire];
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	}
}
#pragma mark - 私有方法
/**
 *  删除观察者
 */
- (void)removeAllObservationInfo
{
	id observer = [self observationInfo];
	NSArray *observerArr = [observer valueForKeyPath:@"_observances"];
	for (id obser in observerArr) {
		NSString *keypath = [obser valueForKeyPath:@"_property._keyPath"];
		NSString *observer = [obser valueForKey:@"_observer"];
		if (keypath && observer) {
			[self removeObserver:self forKeyPath:keypath];
		}
	}
}
/**
 *  监听contentOffset属性
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"contentOffset"]) {
		
		if (isShowInfiniteLoop) [self setInfiniteLoop];
		
		[self setPageControl];
		
		if (isShow3DRotate) {
			for (int i = 0; i < subviewsArray.count; i ++) {
				UIView *view = subviewsArray[i];
				// 添加3D效果
				view.layer.transform = [self transFormPositoin:view.layer.position.x];
			}
		}
	}
}
/**
 *  设置3D效果
 */
- (CATransform3D)transFormPositoin:(CGFloat)positoin
{
	CGFloat changeFloat = fabs((positoin - CGRectGetMidX(self.bounds)) / self.bounds.size.width);
	
	CGFloat angel = (positoin - CGRectGetMidX(self.bounds)) / self.bounds.size.width * M_PI / 10;
	
	// 获取一个标准默认的CATransform3D仿射变换矩阵
	CATransform3D transformRotation = CATransform3DIdentity;
	CATransform3D transformlation = CATransform3DMakeTranslation(0, 0, 0);
	
	/** m34这个属性，CATransform3DRotate获取的旋转如果之前
	 联合的transform不支持透视，那在x、y轴上做旋转是只有frame
	 放大缩小的变化，我们需要的是在旋转的时候要使得离视角近的地方
	 放大，离视角远的地方缩小，就是所谓的视差来形成3D的效果
	 */
	transformRotation.m34 = -1 / 230.0;
	// 获取旋转angle角度后的rotation矩阵
	transformRotation = CATransform3DRotate(transformRotation, angel, 0, 1, 0);
	CATransform3D transformScale = CATransform3DMakeScale(1 - changeFloat * scaleFloat, 1 - changeFloat * scaleFloat, 1);
	
	return CATransform3DConcat(CATransform3DConcat(transformRotation, transformScale), transformlation);
}
/**
 *  设置当前页数
 */
- (void)setPageControl
{
	if (!pageControl) return;
	
	NSInteger pageNum = self.contentOffset.x / self_width - (isShowInfiniteLoop ? 0.5 : (-0.5));
	
	if (isShowInfiniteLoop) {
		if (self.contentOffset.x < self_width * 0.5) {
			pageControl.currentPage = (self.subviews.count - 3);
			return;
		} else if (pageNum > (self.subviews.count - 3)) {
			pageControl.currentPage = 0;
			return;
		}
	}
	
	pageControl.currentPage = pageNum;
}
/**
 *  设置无限循环
 */
- (void)setInfiniteLoop
{
	if (self.contentOffset.x > (self_width * (self.subviews.count - 1))) { // 最后一页
		[self setContentOffset:CGPointMake(self_width, 0)];
	}
	
	if (self.contentOffset.x < 0) { // 第一页
		[self setContentOffset:CGPointMake(self_width * (self.subviews.count - 2), 0)];
	}
}
/**
 *  自动滚轮页数设置
 */
- (void)scroll
{
	numPage++;
	if (numPage > subviewsArray.count) {
		numPage = isShowInfiniteLoop ? 1 : 0;
	}
	
	if (numPage == subviewsArray.count) {
		[self setContentOffset:CGPointMake(isShowInfiniteLoop ? self_width : 0, 0)];
		return;
	}
	
	[UIView animateWithDuration:0.5 animations:^{
		[self setContentOffset:CGPointMake(self_width * numPage, 0)];
	}];
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (!isShowTimer) return;
	[timer invalidate];
	timer = nil;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (!isShowTimer) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		numPage = self.contentOffset.x / screen_width - 1;
		[self addTimer];
	});
	
}

@end
