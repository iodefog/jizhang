//
//  SSJAnnouceMentItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJAnnoucementItem : SSJBaseItem

typedef NS_ENUM(NSUInteger, SSJAnnouceMentType) {
    SSJAnnouceMentTypeNormal = 0,        //  普通公告
    SSJAnnouceMentTypeNew = 1,           //  最新公告
    SSJAnnouceMentTypeHot = 2,           //  热门公告
};

@property(nonatomic, strong) NSString *announcementId;

@property(nonatomic, strong) NSString *announcementTitle;

@property(nonatomic, strong) NSString *announcementContent;

@property(nonatomic, strong) NSString *announcementDate;

@property(nonatomic, strong) NSString *announcementUrl;

@property(nonatomic) BOOL needToShowOnHome;

@property(nonatomic) BOOL haveReaded;

@property(nonatomic) SSJAnnouceMentType announcementType;

@end
