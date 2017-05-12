//
//  SSJDatabase.m
//  SuiShouJi
//
//  Created by old lang on 17/4/21.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJDatabase.h"
#import "SSJDatabaseErrorHandler.h"

@interface FMDatabase ()

- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;

- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;

@end

@interface SSJDatabase ()

@property (nonatomic, copy) NSString *sql;

@end

@implementation SSJDatabase

- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args {
    self.sql = sql;
    BOOL success = [super executeUpdate:sql error:outErr withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
    [self handleErrorIfNeeded];
    return success;
}

- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args {
    self.sql = sql;
    FMResultSet *rs = [super executeQuery:sql withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
    [self handleErrorIfNeeded];
    return rs;
}

- (void)handleErrorIfNeeded {
    if (self.shouldHandleError && [self hadError]) {
        NSError *error = [self lastError];
        NSString *desc = [NSString stringWithFormat:@"code:%d  description:%@  sql:%@", (int)error.code, error.localizedDescription, self.sql];
        NSError *customError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:desc}];
        [SSJDatabaseErrorHandler handleError:customError];
    }
}

@end
