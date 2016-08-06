//
//  ViewController.m
//  TT3DScrollView
//
//  Created by hehe.Mr on 16/8/3.
//  Copyright © 2016年 Vinson. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+TTExtention.h"

#define screen_width	[UIScreen mainScreen].bounds.size.width
#define pageNumber		8

@interface ViewController ()
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, screen_width, 200)];
	
	// 如果只是添加图片。实现此方法即可，传图片名称（如image0/image1....传image），pageCount传图片的个数（包括实现无限滚轮多余的两张）
	if (/* DISABLES CODE */ (1)) {
		[scrollView addSubviewsWithImageName:@"image" pageCount:pageNumber];
	} else {
		// 如果添加的不是图片，而是其他控件（如UIButtton），实现setSubviewsFrame方法实现初始化
		for (NSInteger i = 0; i < pageNumber; i++) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setBackgroundImage:[UIImage imageNamed:[@"image" stringByAppendingString:[@(i) stringValue]]] forState:UIControlStateNormal];
			[scrollView addSubview:button];
		}
		
		// 设置frame
		[scrollView setSubviewsFrame];
	}
	
	/** 选择功能 */
	// 设置3D滚动效果
	[scrollView add3DRotate];
	// 无限滚轮，（必须添加最后一张图片在首部，第一张在尾部）
	[scrollView addInfiniteLoop];
	// 添加自动滚轮定时器
	[scrollView addTimer];
	// 添加scrollView
	[self.view addSubview:scrollView];
	// 一定在添加scrollView之后
	[scrollView addPageControl];
	
}

@end
