//
//  SSJBooksMergeHelper.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBooksMergeHelper : NSObject

- (void)startMergeWithSourceBooksId:(NSString *)sourceBooksId
                      targetBooksId:(NSString *)targetBooksId
                            Success:(void(^)())success
                            failure:(void (^)(NSError *error))failure;

- (NSArray *)getAllBooksItemWithExceptionId:(NSString *)exceptionId;

- (NSNumber *)getChargeCountForBooksId:(NSString *)booksId;

- (BOOL)isShareBooksOrNotWithBooksId:(NSString *)booksId;
@end
