//
//  SSJBooksTypeMergeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJBooksTypeTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* booksName;

@property (nonatomic, retain) NSString* booksColor;

@property (nonatomic, retain) NSString* booksIcon;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) int booksOrder;

@property (nonatomic, assign) SSJBooksType parentType;


WCDB_PROPERTY(booksId)
WCDB_PROPERTY(booksName)
WCDB_PROPERTY(booksColor)
WCDB_PROPERTY(booksIcon)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(booksOrder)
WCDB_PROPERTY(parentType)


@end
