//
//  SSJProductAdviceTableHeaderView.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJProductAdviceTableHeaderView : UIView

/**
 头高度
 */
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) SSJAdviceType defaultAdviceType;

- (void)clearAdviceContext;


@end
