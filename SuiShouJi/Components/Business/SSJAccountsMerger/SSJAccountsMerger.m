//
//  SSJAccountsMerger.m
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAccountsMerger.h"
#import "SSJAccountsMergerTables.h"
#import "SSJDatabaseQueue.h"

@implementation SSJAccountsMerger

+ (void)mergeDataFromUserID:(NSString *)userId1
                   toUserID:(NSString *)userId2
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure {
    
    NSSet *firstTierSet = [NSSet setWithObjects:[SSJAccountsMergeRemindTable class],
                                                [SSJAccountsMergeMemberTable class],
                                                [SSJAccountsMergeFundInfoTable class],
                                                [SSJAccountsMergeBooksTable class], nil];
    
    NSSet *secondTierSet = [NSSet setWithObjects:[SSJAccountsMergeCreditTable class],
                                                 [SSJAccountsMergeBIllTypeTable class],
                                                 [SSJAccountsMergeLoanTable class], nil];
    
    NSSet *thirdTierSet = [NSSet setWithObjects:[SSJAccountsMergePeriodChargeTable class], nil];
    
    NSSet *fourthTierSet = [NSSet setWithObjects:[SSJAccountsMergeChargeTable class], nil];
    
    NSSet *fifthTierSet = [NSSet setWithObjects:[SSJAccountsMergeMemberChargeTable class], nil];
    
    NSArray *tableTree = @[firstTierSet,
                           secondTierSet,
                           thirdTierSet,
                           fourthTierSet,
                           fifthTierSet];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        int64_t version = 0;
        __block NSError *error = nil;
        
        for (NSSet *tierSet in tableTree) {
            for (Class tableCalss in tierSet) {
                
                if (![tableCalss conformsToProtocol:@protocol(SSJAccountsMerge)]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@""}];
                            failure(error);
                        });
                    }
                    return;
                }
                
                if (![tableCalss mergeFromUserID:userId1 toUserId:userId2 version:version inDatabase:db error:&error]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure(error);
                        });
                    }
                    return;
                }
            }
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)discardDataFromUserID:(NSString *)userId1
                     toUserID:(NSString *)userId2
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure {
    
}

@end
