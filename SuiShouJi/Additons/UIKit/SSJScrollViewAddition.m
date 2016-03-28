//
//  SSJScrollViewAddition.m
//  MoneyMore
//
//  Created by old lang on 15-6-4.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJScrollViewAddition.h"

@implementation UIScrollView (SSJCategory)

- (void)scrollSubview:(UIView *)view toContentPosition:(UITableViewScrollPosition)position animated:(BOOL)animated {
    if ([view isDescendantOfView:self]) {
        
        CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
        contentFrame.origin = CGPointMake(CGRectGetMinX(contentFrame) + self.contentOffset.x, CGRectGetMinY(contentFrame) + self.contentOffset.y);
        
        CGFloat offsetY = 0.0;
        CGRect subviewFrame = [self convertRect:view.bounds fromView:view];
        
        switch (position) {
            case UITableViewScrollPositionNone:
                break;
                
            case UITableViewScrollPositionTop:
                offsetY = CGRectGetMinY(subviewFrame) - CGRectGetMinY(contentFrame);
                break;
                
            case UITableViewScrollPositionMiddle:
                offsetY = CGRectGetMidY(subviewFrame) - CGRectGetMidY(contentFrame);
                break;
                
            case UITableViewScrollPositionBottom:
                offsetY = CGRectGetMaxY(subviewFrame) - CGRectGetMaxY(contentFrame);
                break;
        }
        
        offsetY += self.contentOffset.y;
        
        if (offsetY > self.contentOffset.y) {
            CGFloat maxOffsetY = self.contentSize.height - self.height;
            maxOffsetY = MAX(maxOffsetY, 0);
            maxOffsetY += self.contentInset.bottom;
            offsetY = MIN(offsetY, maxOffsetY);
        } else {
            CGFloat maxOffsetY =  - self.contentInset.top;
            offsetY = MAX(offsetY, maxOffsetY);
        }
        
        [self setContentOffset:CGPointMake(0, offsetY) animated:animated];
    }
}

- (void)scrollSubview:(UIView *)view toContentPositionIfNeeded:(UITableViewScrollPosition)position animated:(BOOL)animated {
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    contentFrame.origin = CGPointMake(CGRectGetMinX(contentFrame) + self.contentOffset.x, CGRectGetMinY(contentFrame) + self.contentOffset.y);
    CGRect subviewFrame = [self convertRect:view.bounds fromView:view];
    
    if (!CGRectContainsRect(contentFrame, subviewFrame)) {
        [self scrollSubview:view toContentPosition:position animated:animated];
    }
}

@end