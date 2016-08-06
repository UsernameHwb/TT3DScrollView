//
//  UIScrollView+TTExtention.h
//  TT3DScrollView
//
//  Created by hehe.Mr on 16/8/3.
//  Copyright © 2016年 Vinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (TTExtention) <UIScrollViewDelegate>
/**
 *  添加子视图
 */
- (void)addSubviewsWithImageName:(NSString *)imageName pageCount:(NSInteger)pageCount;
/**
 *  如果添加的不是UIImageView，而是其他控件（如UIButtton），实现此方法实现初始化
 */
- (void)setSubviewsFrame;
/**
 *  实现3D效果
 */
- (void)add3DRotate;
/**
 *  无线循环
 */
- (void)addInfiniteLoop;
/**
 *  添加页码PageControl
 */
- (void)addPageControl;
/**
 *  添加定时器
 */
- (void)addTimer;
@end
