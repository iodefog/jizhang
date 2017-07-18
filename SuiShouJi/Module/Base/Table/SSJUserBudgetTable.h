//
//  SSJUserBudgetTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserBudgetTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* budgetId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* budgetType;

@property (nonatomic, assign) double money;

@property (nonatomic, assign) double remindMoney;

@property (nonatomic, retain) NSString* startDate;

@property (nonatomic, retain) NSString* endDate;

@property (nonatomic, assign) int budgetState;

@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, retain) NSString* billType;

@property (nonatomic, assign) int needRemind;

@property (nonatomic, assign) int hasRemind;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, assign) int isLastDay;


WCDB_PROPERTY(budgetId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(budgetType)
WCDB_PROPERTY(money)
WCDB_PROPERTY(remindMoney)
WCDB_PROPERTY(startDate)
WCDB_PROPERTY(endDate)
WCDB_PROPERTY(budgetState)
WCDB_PROPERTY(addDate)
WCDB_PROPERTY(billType)
WCDB_PROPERTY(needRemind)
WCDB_PROPERTY(hasRemind)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(version)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(isLastDay)

@end
