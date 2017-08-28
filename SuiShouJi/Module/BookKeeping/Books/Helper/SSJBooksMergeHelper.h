//
//  SSJBooksMergeHelper.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBooksMergeHelper : NSObject

+ (void)startMergeWithSourceBooksId:(NSString *)sourceBooksId
                      targetBooksId:(NSString *)targetBooksId
                            Success:(void(^)())success
                            failure:(void (^)(NSError *error))failure;

+ (void)getAllBooksItemWithExceptionId:(NSString *)exceptionId
                               Success:(void(^)(NSArray * bookList))success
                               failure:(void (^)(NSError *error))failure;

+ (void)getChargeCountForBooksId:(NSString *)booksId
                         Success:(void(^)(NSNumber *chargeCount))success
                         failure:(void (^)(NSError *error))failure ;

@end
