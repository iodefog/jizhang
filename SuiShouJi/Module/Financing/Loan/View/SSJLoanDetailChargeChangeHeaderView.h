//
//  SSJLoanDetailChargeChangeHeaderView.h
//  SuiShouJi
//
//  Created by old lang on 16/11/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJLoanDetailChargeChangeHeaderView : UIView

@property (nonatomic) BOOL expanded;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) void (^tapHandle)(SSJLoanDetailChargeChangeHeaderView *);

- (void)updateAppearance;

@end
