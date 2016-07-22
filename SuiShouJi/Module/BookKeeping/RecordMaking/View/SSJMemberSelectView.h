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

@property (nonatomic, copy) void(^comfirmBlock)(NSArray *selectedMemberIds , NSArray *selectedMemberNames);

@property(nonatomic, strong) NSMutableArray *selectedMemberIds;

@property(nonatomic, strong) NSMutableArray *selectedMemberNames;

- (void)show;

- (void)dismiss;

@end
