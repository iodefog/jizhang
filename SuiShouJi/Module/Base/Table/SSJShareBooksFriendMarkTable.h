//
//  SSJShareBooksFriendMarkTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJShareBooksFriendMarkTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* friendId;

@property (nonatomic, retain) NSString* friendMark;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

WCDB_PROPERTY(userId)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(friendId)
WCDB_PROPERTY(friendMark)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)

@end
