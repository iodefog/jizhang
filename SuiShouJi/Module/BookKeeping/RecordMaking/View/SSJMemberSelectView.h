//
//  SSJMemberSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMemberSelectView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) void(^dismissBlock)();

@property (nonatomic, copy) void(^comfirmBlock)(NSArray *selectedMemberItems);

@property (nonatomic, copy) void(^manageBlock)();

@property (nonatomic, copy) void(^addNewMemberBlock)();

@property(nonatomic, strong) NSMutableArray *selectedMemberItems;

- (void)show;

- (void)dismiss;

@end
