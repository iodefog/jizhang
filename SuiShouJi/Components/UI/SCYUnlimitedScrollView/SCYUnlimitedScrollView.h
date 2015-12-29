//
//  SCYUnlimitedScrollView.h
//  MoneyMore
//
//  Created by old lang on 15/7/14.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  无限制滚动scrollView

#import <UIKit/UIKit.h>

@protocol SCYUnlimitedScrollViewDataSource;
@protocol SCYUnlimitedScrollViewDelegate;

@interface SCYUnlimitedScrollView : UIView

//  数据源协议
@property (nonatomic, assign) id <SCYUnlimitedScrollViewDataSource> dataSource;

//  代理协议
@property (nonatomic, assign) id <SCYUnlimitedScrollViewDelegate> delegate;

//  当前滚动的下标
@property (nonatomic, assign) NSInteger currentIndex;

//  滚动到下一张页面
- (void)scrollToNextPage;

//  滚动到上一张页面
- (void)scrollToPreviousPage;

//  重载子视图
- (void)reloadSubViews;

@end


@protocol SCYUnlimitedScrollViewDataSource <NSObject>

//  返回scrollView中有几个子视图
- (NSUInteger)numberOfPagesInScrollView:(SCYUnlimitedScrollView *)scrollView;

//  返回下标index对应的视图
- (UIView *)scrollView:(SCYUnlimitedScrollView *)scrollView subViewAtPageIndex:(NSUInteger)index;

@end

@protocol SCYUnlimitedScrollViewDelegate <NSObject>

//  完成滚动的回调方法，index是当前的下标
- (void)scrollView:(SCYUnlimitedScrollView *)scrollView didScrollAtPageIndex:(NSUInteger)index;

@end
