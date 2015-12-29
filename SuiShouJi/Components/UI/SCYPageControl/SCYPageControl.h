//
//  SCYPageControl.h
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  分页控件

#import <UIKit/UIKit.h>

@interface SCYPageControl : UIControl

// 页标总数 default is 0
@property (nonatomic) NSUInteger numberOfPages;

// 当前选中的页标 default is 0
@property (nonatomic) NSUInteger currentPage;

// 页标图片之间的距离 default is 0
@property (nonatomic) CGFloat spaceBetweenPages;

// 未选中的页标图片 default is nil
@property (nonatomic, strong) UIImage *pageImage;

// 选中的页标图片 default is nil
@property (nonatomic, strong) UIImage *currentPageImage;

@end
