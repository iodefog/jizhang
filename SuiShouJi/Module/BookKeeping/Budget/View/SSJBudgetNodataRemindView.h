//
//  SSJBudgetNodataRemindView.h
//  SuiShouJi
//
//  Created by old lang on 16/7/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBudgetNodataRemindView : UIView

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

/**subTitle*/
@property (nonatomic, copy) NSString *subTitle;

- (void)updateAppearance;

@end
