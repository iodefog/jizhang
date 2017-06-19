//
//  SSJMemberSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJChargeMemberItem;

@interface SSJMemberSelectView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) void(^dismissBlock)();

@property (nonatomic, copy) void(^showBlock)();

@property (nonatomic, copy) void(^selectedMemberDidChangeBlock)(NSArray *selectedMemberItems);

@property (nonatomic, copy) void(^manageBlock)(NSMutableArray *items);

@property (nonatomic, copy) void(^addNewMemberBlock)();

@property(nonatomic, strong, readonly) NSMutableArray<SSJChargeMemberItem *> *selectedMemberItems;

@property(nonatomic, strong) NSString *chargeId;

/**
 周期记账配置id
 */
@property(nonatomic, strong) NSString *preiodConfigId;

- (void)show;

- (void)dismiss;

- (void)reloadData:(void(^)())completion;

- (void)addSelectedMemberItem:(SSJChargeMemberItem *)item;

@end
