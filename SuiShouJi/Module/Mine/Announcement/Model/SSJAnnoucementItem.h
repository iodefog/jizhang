//
//  SSJAnnouceMentItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJAnnoucementItem : SSJBaseCellItem

typedef NS_ENUM(NSUInteger, SSJAnnouceMentType) {
    SSJAnnouceMentTypeNormal = 0,        //  普通公告
    SSJAnnouceMentTypeNew = 1,           //  最新公告
    SSJAnnouceMentTypeHot = 2,           //  热门公告
};

@property(nonatomic, copy) NSString *announcementImg;

@property(nonatomic, copy) NSString *announcementId;

@property(nonatomic, copy) NSString *announcementTitle;

@property(nonatomic, copy) NSString *announcementContent;

@property(nonatomic, copy) NSString *announcementDate;

@property(nonatomic, copy) NSString *announcementUrl;
@property(nonatomic, copy) NSString *announcementNumber; //公告点击次数

@property(nonatomic) BOOL needToShowOnHome;

@property(nonatomic) BOOL haveReaded;

@property(nonatomic) SSJAnnouceMentType announcementType;

@end
