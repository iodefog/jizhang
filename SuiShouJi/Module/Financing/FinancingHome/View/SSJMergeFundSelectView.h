//
//  SSJMergeFundSelectView.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"

@interface SSJMergeFundSelectView : UIView

@property (nonatomic, strong) NSArray *fundsArr;

- (void)showWithSelectedItem:(SSJBaseCellItem *)item;

- (void)dismiss;

@property (nonatomic, copy) void(^didSelectFundItem)(SSJBaseCellItem *fundItem, NSString *selectParent);

@property (nonatomic, copy) void(^dismissBlock)();

@end
