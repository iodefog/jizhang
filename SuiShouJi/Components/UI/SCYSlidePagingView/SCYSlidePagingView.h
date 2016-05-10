//
//  SCYSlidePagingView.h
//  SCYSlidePagingControl
//
//  Created by old lang on 15-4-30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCYSlidePagingHeaderView.h"

@protocol SCYSlidePagingViewDataSource;
@protocol SCYSlidePagingViewDelegate;


@interface SCYSlidePagingView : UIView

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

@property (nonatomic, strong, readonly) SCYSlidePagingHeaderView *headerView;

@property (nonatomic, strong, readonly) UIScrollView *bodyView;

@property (nonatomic, assign) id <SCYSlidePagingViewDataSource> dataSource;

@property (nonatomic, assign) id <SCYSlidePagingViewDelegate> delegate;

- (void)reload;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end


@protocol SCYSlidePagingViewDataSource <NSObject>

- (NSUInteger)numberOfPagesInSlidePagingView:(SCYSlidePagingView *)slidePagingView;

- (UIView *)slidePagingView:(SCYSlidePagingView *)slidePagingView contentViewAtPagingIndex:(NSUInteger)index;

- (NSString *)slidePagingView:(SCYSlidePagingView *)slidePagingView headerTitleAtPagingIndex:(NSUInteger)index;

@end

@protocol SCYSlidePagingViewDelegate <NSObject>

@optional
- (BOOL)slidePagingView:(SCYSlidePagingView *)slidePagingView shouldMoveToPageAtIndex:(NSUInteger)index;

- (void)slidePagingView:(SCYSlidePagingView *)slidePagingView willMoveToPageAtIndex:(NSUInteger)index;

- (void)slidePagingView:(SCYSlidePagingView *)slidePagingView didMoveToPageAtIndex:(NSUInteger)index;


@end
