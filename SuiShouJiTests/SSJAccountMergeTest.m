//
//  SSJAccountMergeTest.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSJAccountMergeManager.h"
#import "NSDate+DateTools.h"

@interface SSJAccountMergeTest : XCTestCase

@property (nonatomic, strong) SSJAccountMergeManager *manager;

@end

@implementation SSJAccountMergeTest

- (void)setUp {
    [super setUp];
    self.manager = [[SSJAccountMergeManager alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSDate *startDate = [NSDate dateWithYear:2017 month:7 day:25 hour:0 minute:0 second:0];

    NSDate *endDate = [NSDate dateWithYear:2017 month:7 day:25 hour:23 minute:59 second:59];
    
    [self.manager startMergeWithSourceUserId:@"90d7a2ba-d4bf-4f1e-8af9-c8ff13c2c900" targetUserId:@"5a881e09-7402-4e2d-8729-c25bb6742bdc" startDate:startDate endDate:endDate Success:^{
        XCTAssert(@"合并成功");
    } failure:^(NSError *error) {
        XCTAssertNotNil(error,@"合并失败");
    }];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
