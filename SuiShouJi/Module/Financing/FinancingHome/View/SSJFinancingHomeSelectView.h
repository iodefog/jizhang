//
//  SSJFinancingHomeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJFinancingHomeSelectView : UIView 


- (void)showInView:(UIView *)view atPoint:(CGPoint)point;

- (void)dismiss;

- (void)setItems:(NSArray *)items andSelectFundid:(NSString *)fundids;

@end
