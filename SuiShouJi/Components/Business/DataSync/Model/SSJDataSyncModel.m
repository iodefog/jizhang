//
//  SSJDataSyncModel.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSyncModel.h"
#import <objc/runtime.h>

@implementation SSJDataSyncModel

+ (instancetype)modelWithResultSet:(FMResultSet *)result {
    SSJDataSyncModel *model = [[self alloc] init];
//    model.CUSERID = [result stringForColumn:@"CUSERID"];
//    model.CWRITEDATE = [result stringForColumn:@"CWRITEDATE"];
//    model.IVERSION = [result intForColumn:@"IVERSION"];
//    model.OPERATORTYPE = [result intForColumn:@"OPERATORTYPE"];
    
    NSArray *properties = [self getAllProperties];
    for (NSString *property in properties) {
        [model setValue:[result stringForColumn:property] forKey:property];
    }
    
    return model;
}

+ (NSArray *)primaryKeys {
    return nil;
}

+ (NSArray *)getProperties {
    u_int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

+ (NSArray *)getAllProperties {
    if (self == [SSJDataSyncModel class]) {
        return [self getProperties];
    }
    
    NSMutableArray *allProperty = [NSMutableArray arrayWithArray:[[self superclass] getProperties]];
    [allProperty addObjectsFromArray:[self getProperties]];
    return allProperty;
}

@end
