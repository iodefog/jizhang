//
//  SSJShareBooksTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJShareBooksTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* creatorId;

@property (nonatomic, retain) NSString* adminId;

@property (nonatomic, retain) NSString* booksName;

@property (nonatomic, retain) NSString* booksColor;

@property (nonatomic, assign) int booksParent;

@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, assign) int booksOrder;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int operatorType;


WCDB_PROPERTY(booksId)
WCDB_PROPERTY(creatorId)
WCDB_PROPERTY(adminId)
WCDB_PROPERTY(booksName)
WCDB_PROPERTY(booksColor)
WCDB_PROPERTY(booksParent)
WCDB_PROPERTY(addDate)
WCDB_PROPERTY(booksOrder)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(version)
WCDB_PROPERTY(operatorType)

@end
