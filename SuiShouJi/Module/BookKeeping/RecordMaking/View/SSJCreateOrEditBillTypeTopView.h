//
//  SSJCreateOrEditBillTypeTopView.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCreateOrEditBillTypeTopView : UIView

@property (nonatomic, strong) UIColor *billTypeColor;

@property (nonatomic, strong) UIImage *billTypeIcon;

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, copy) void (^tapColorAction)();

@end
