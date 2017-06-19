//
//  SSJUserDefaultDataCreater.m
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultDataCreater.h"
#import "SSJUserDefaultFundCreater.h"
#import "SSJUserDefaultBooksCreater.h"
#import "SSJUserDefaultMembersCreater.h"
#import "SSJUserDefaultBillTypesCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultDataCreater

+ (void)createAllDefaultDataWithUserId:(NSString *)userId error:(NSError **)error {
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        [self createAllDefaultDataWithUserId:userId inDatabase:db error:error];
    }];
}

+ (void)asyncCreateAllDefaultDataWithUserId:(NSString *)userId
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSError *error = nil;
        [self createAllDefaultDataWithUserId:userId inDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
        } else {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        }
    }];
}

+ (void)createAllDefaultDataWithUserId:(NSString *)userId inDatabase:(SSJDatabase *)db error:(NSError **)error {
    if (!userId.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"userid无效"}];
        }
        return;
    }
    for (Class createrClass in [self defaultDataCreaterClass]) {
        NSError *tError = nil;
        if ([createrClass conformsToProtocol:@protocol(SSJUserDefaultDataCreaterProtocol)]) {
            [createrClass createDefaultDataTypeForUserId:userId inDatabase:db error:&tError];
        }
        
        if (tError) {
            if (error) {
                *error = tError;
            }
            return;
        }
    }
}

+ (NSArray *)defaultDataCreaterClass {
    return @[[SSJUserDefaultFundCreater class],
             [SSJUserDefaultBooksCreater class],
             [SSJUserDefaultMembersCreater class],
             [SSJUserDefaultBillTypesCreater class]];
}

@end
