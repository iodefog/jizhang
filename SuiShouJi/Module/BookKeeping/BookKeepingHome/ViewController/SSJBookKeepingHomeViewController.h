//
//  SJJBookKeepingHomeViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJHomeTableView.h"

@interface SSJBookKeepingHomeViewController : SSJBaseViewController
<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) BOOL hasLoad;
@property(nonatomic) BOOL  allowRefresh;

@property(nonatomic, strong) SSJHomeTableView *tableView;

//首页动画加载
-(void)reloadWithAnimation;

@end
