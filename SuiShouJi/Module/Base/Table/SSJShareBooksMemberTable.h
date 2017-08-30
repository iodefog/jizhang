//
//  SSJShareBooksMemberTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJShareBooksMemberTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* memberId;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* joinDate;

@property (nonatomic, assign) SSJShareBooksMemberState memberState;

@property (nonatomic, retain) NSString* memberIcon;

@property (nonatomic, retain) NSString* memberColor;

@property (nonatomic, retain) NSString* leaveDate;


WCDB_PROPERTY(memberId)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(joinDate)
WCDB_PROPERTY(memberState)
WCDB_PROPERTY(memberIcon)
WCDB_PROPERTY(memberColor)
WCDB_PROPERTY(leaveDate)

@end
