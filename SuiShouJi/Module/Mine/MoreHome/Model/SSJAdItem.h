//
//  SSJBannerItem.h
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"
#import "SSJListAdItem.h"
#import "SSJBooksAdBanner.h"

@interface SSJAdItem : SSJBaseItem

@property(nonatomic, strong) NSArray *bannerItems;

@property(nonatomic, strong) NSArray *listAdItems;

@property(nonatomic, strong) SSJBooksAdBanner *booksAdItem;

@end
