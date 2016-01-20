//
//  SSJDataSynchronizerTests.m
//  SuiShouJi
//
//  Created by old lang on 16/1/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SSJUtil.h"
#import "SSJDataSyncHelper.h"

#import "SSJDatabaseQueue.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserChargeSyncTable.h"

@interface SSJDataSynchronizerTests : XCTestCase

@end

@implementation SSJDataSynchronizerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testQueryRecordsForSync {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
        
        NSArray *userBillRecords = [SSJUserBillSyncTable queryRecordsForSyncInDatabase:db];
        for (NSDictionary *record in userBillRecords) {
            XCTAssert([record isKindOfClass:[NSDictionary class]], @"record is not subclass of NSDictionary");
            XCTAssertGreaterThan([record[@"IVERSION"] intValue], lastSyncVersion, @"record IVERSION should greater than lastSyncVersion");
            XCTAssert([record[@"CUSERID"] isEqualToString:SSJUSERID()], @"record CUSERID is not current user id");
        }
        
        NSArray *fundInfoRecords = [SSJFundInfoSyncTable queryRecordsForSyncInDatabase:db];
        for (NSDictionary *record in fundInfoRecords) {
            XCTAssert([record isKindOfClass:[NSDictionary class]], @"record is not subclass of NSDictionary");
            XCTAssertGreaterThan([record[@"IVERSION"] intValue], lastSyncVersion, @"record IVERSION should greater than lastSyncVersion");
            XCTAssert([record[@"CUSERID"] isEqualToString:SSJUSERID()], @"record CUSERID is not current user id");
        }
        
        NSArray *userChargeRecords = [SSJUserChargeSyncTable queryRecordsForSyncInDatabase:db];
        for (NSDictionary *record in userChargeRecords) {
            XCTAssert([record isKindOfClass:[NSDictionary class]], @"record is not subclass of NSDictionary");
            XCTAssertGreaterThan([record[@"IVERSION"] intValue], lastSyncVersion, @"record IVERSION should greater than lastSyncVersion");
            XCTAssert([record[@"CUSERID"] isEqualToString:SSJUSERID()], @"record CUSERID is not current user id");
        }
    }];
}

- (void)testMergeUserBillRecords {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    
    NSString *userID = SSJUUID();
    NSString *billID = @"1000";
    int state = 0;
    NSString *writeDate = [format stringFromDate:[NSDate date]];
    int version = [NSDate date].timeIntervalSince1970;
    int operatortype = 0;
    

    NSArray *userBillRecords = @[];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
