//
//  SSJSearchHistoryTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJSearchHistoryTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* searchContent;

@property (nonatomic, retain) NSString* historyId;

@property (nonatomic, retain) NSString* searchDate;

WCDB_PROPERTY(userId)
WCDB_PROPERTY(searchContent)
WCDB_PROPERTY(historyId)
WCDB_PROPERTY(searchDate)

@end
