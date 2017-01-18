//
//  SSJHomeBillStickyNoteView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/1/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJHomeBillStickyNoteView : UIView
extern NSString *const SSJShowBillNoteKey;
//打开2016账单
@property (nonatomic, copy) void(^openBillNoteBlock)();

//关闭账单
@property (nonatomic, copy) void(^closeBillNoteBlock)();

@end
