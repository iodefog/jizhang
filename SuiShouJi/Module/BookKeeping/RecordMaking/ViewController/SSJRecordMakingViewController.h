//
//  SSJRecordMakingViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJCustomKeyboard.h"

@interface SSJRecordMakingViewController : SSJBaseViewController<SSJCustomKeyboardDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;

/**
 *  区分新建还是修改
 */
typedef NS_ENUM(NSUInteger, SSJRecordMakingType){
    SSJRecordMakingTypeNew = 0,
    SSJRecordMakingTypeEdite
};


@end
