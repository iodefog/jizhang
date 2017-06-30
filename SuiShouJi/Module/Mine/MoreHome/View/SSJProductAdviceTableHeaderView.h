//
//  SSJProductAdviceTableHeaderView.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSUInteger, SSJAdviceType) {
//    SSJAdviceTypeAdvice,//产品建议
//    SSJAdviceTypeFault,//使用故障
//    SSJAdviceTypeTuCao,//我要吐槽
//};

@interface SSJProductAdviceTableHeaderView : UIView

/**
 头高度
 */
@property (nonatomic, assign) CGFloat headerHeight;

- (void)clearAdviceContext;


@end
