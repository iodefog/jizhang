//
//  SSJProductAdviceTableHeaderView.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SSJProductAdviceTableHeaderViewDelegate<NSObject>
- (void)submitAdviceButtonClickedWithMessage:(NSString *)messageStr additionalMessage:(NSString *)addMessage;
@end
@interface SSJProductAdviceTableHeaderView : UIView
/**
 头高度
 */
@property (nonatomic, assign) CGFloat headerHeight;
- (void)clearAdviceContext;

/**
 <#注释#>
 */
@property (nonatomic, weak) id<SSJProductAdviceTableHeaderViewDelegate>delegate;
@end
