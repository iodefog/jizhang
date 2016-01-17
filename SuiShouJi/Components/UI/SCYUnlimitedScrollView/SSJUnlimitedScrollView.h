//
//  SSJUnlimitedScrollView.h
//  MoneyMore
//
//  Created by old lang on 15/7/14.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  无限制滚动scrollView

#import <UIKit/UIKit.h>

@protocol SSJUnlimitedScrollViewDataSource;
@protocol SSJUnlimitedScrollViewDelegate;

@interface SSJUnlimitedScrollView : UIView

//  数据源协议
@property (nonatomic, assign) id <SSJUnlimitedScrollViewDataSource> dataSource;

//  代理协议
@property (nonatomic, assign) id <SSJUnlimitedScrollViewDelegate> delegate;

//  当前滚动的下标
@property (nonatomic, assign) NSInteger currentIndex;

//  滚动到下一张页面
- (void)scrollToNextPage;

//  滚动到上一张页面
- (void)scrollToPreviousPage;

//  重载子视图
- (void)reloadSubViews;

@end


@protocol SSJUnlimitedScrollViewDataSource <NSObject>

//  返回scrollView中有几个子视图
- (NSUInteger)numberOfPagesInScrollView:(SSJUnlimitedScrollView *)scrollView;

//  返回下标index对应的视图
- (UIView *)scrollView:(SSJUnlimitedScrollView *)scrollView subViewAtPageIndex:(NSUInteger)index;

@end

@protocol SSJUnlimitedScrollViewDelegate <NSObject>

//  完成滚动的回调方法，index是当前的下标
- (void)scrollView:(SSJUnlimitedScrollView *)scrollView didScrollAtPageIndex:(NSUInteger)index;

@end
