//
//  SSJAnnouncementsListViewController.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJAnnoucementItem.h"

@interface SSJAnnouncementsListViewController : SSJNewBaseTableViewController

@property(nonatomic, strong) NSMutableArray <SSJAnnoucementItem *> *items;

@property(nonatomic) NSInteger totalPage;

@end
