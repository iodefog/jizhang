//
//  SSJMineHomeBannerHeader.h
//  SuiShouJi
//
//  Created by ricky on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBannerItem.h"
#import "SCYWinCowryHomeBannerView.h"

@interface SSJMineHomeBannerHeader : UITableViewHeaderFooterView

@property(nonatomic, strong) NSArray <SSJBannerItem *> *items;

@property (nonatomic, strong) SCYWinCowryHomeBannerView *bannerView;

@end
