//
//  SSJDataBaseHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataBaseHelper.h"
#import <WCDB/WCDB.h>
#import "SSJUserChargeTable.h"
#import "SSJBooksTypeTable.h"

@interface SSJDataBaseHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJDataBaseHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        bool isExist = NO;
        isExist = [self.db isTableExists:@"bk_books_type"] ;
//        NSArray<SSJUserChargeTable *> *message = [self.db getObjectsOfClass:SSJBooksTypeMergeTable.class
//                                                                       fromTable:@"bk_books_type"
//                                                                         where:SSJBooksTypeMergeTable.userId == SSJUSERID() && SSJBooksTypeMergeTable.operatorType != 2];
//
//        WCTMultiSelect *multiSelect = [[self.db prepareSelectMultiObjectsOnResults:{
//            SSJUserChargeTable.booksId.inTable(@"bk_user_charge"),
//            SSJBooksTypeMergeTable.booksId.inTable(@"bk_books_type")
//        } fromTables:@[ @"bk_user_charge", @"bk_books_type" ]] where:SSJUserChargeTable.booksId.inTable(@"bk_user_charge") == SSJBooksTypeMergeTable.booksId.inTable(@"bk_books_type")];
//        
//        while ([multiSelect nextMultiObject]) {
//            WCTMultiObject *multiObject = [multiSelect nextMultiObject];
//            NSLog(@"%@",multiObject);
//        }
        
        [WCTStatistics SetGlobalTrace:^(WCTTag, NSDictionary<NSString *,NSNumber *> *, NSInteger) {
            
            
        }];
        
        [WCTStatistics SetGlobalErrorReport:^(WCTError *) {
            
        }];
        
            WCTMultiSelect *select = [[self.db prepareSelectMultiObjectsOnResults:{
            SSJUserChargeTable.booksId.inTable(@"bk_user_charge"),
            SSJBooksTypeTable.booksId.inTable(@"bk_books_type"),
            SSJUserChargeTable.userId.inTable(@"bk_user_charge"),
        }
                                                                    fromTables:@[ @"bk_books_type", @"bk_user_charge" ]] where:SSJUserChargeTable.booksId.inTable(@"bk_user_charge") == SSJBooksTypeTable.booksId.inTable(@"bk_books_type") && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == SSJUSERID()];
        

        while ([select nextMultiObject]) {

        }
    }
    return self;
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}



@end
