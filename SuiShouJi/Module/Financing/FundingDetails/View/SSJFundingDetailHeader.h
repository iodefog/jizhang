//
//  SSJFundingDetailHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFundingDetailHeader : UIView

@property(nonatomic, strong) SSJFinancingHomeitem *item;

- (void)updateAfterThemeChange;

@end
