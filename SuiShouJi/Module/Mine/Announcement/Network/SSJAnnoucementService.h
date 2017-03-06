//
//  SSJAnnoucementService.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJAnnoucementItem.h"

static NSString *const kLastAnnoucementIdKey = @"kLastAnnoucementIdKey";

@interface SSJAnnoucementService : SSJBaseNetworkService

@property(nonatomic, strong) NSArray <SSJAnnoucementItem *> *annoucements;

@property(nonatomic) NSInteger currentPage;

@property(nonatomic) NSInteger totalPage;

@property(nonatomic) BOOL hasNewAnnouceMent;

- (void)requestAnnoucementsWithPage:(NSInteger)page;

@end
