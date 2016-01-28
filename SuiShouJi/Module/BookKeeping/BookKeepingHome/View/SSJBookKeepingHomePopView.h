//
//  SSJBookKeepingHomePopView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBookKeepingHomePopView : UIView

typedef void(^loginBtnClickBlock)();

@property (nonatomic, copy) loginBtnClickBlock loginBtnClickBlock;

typedef void(^registerBtnClickBlock)();

@property (nonatomic, copy) registerBtnClickBlock registerBtnClickBlock;

+ (id)BookKeepingHomePopView;
@end
