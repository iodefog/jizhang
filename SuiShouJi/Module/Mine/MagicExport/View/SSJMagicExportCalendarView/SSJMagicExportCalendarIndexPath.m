//
//  SSJMagicExportCalendarViewIndexPath.m
//  SuiShouJi
//
//  Created by old lang on 16/4/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarIndexPath.h"

@interface SSJMagicExportCalendarIndexPath ()

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) NSInteger index;

@end

@implementation SSJMagicExportCalendarIndexPath

+ (instancetype)indexPathForSection:(NSInteger)sectioin row:(NSInteger)row index:(NSInteger)index {
    SSJMagicExportCalendarIndexPath *path = [[SSJMagicExportCalendarIndexPath alloc] init];
    path.section = sectioin;
    path.row = row;
    path.index = index;
    return path;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>:%@", self, @{@"section":@(_section),
                                                          @"row":@(_row),
                                                          @"index":@(_index)}];
}

@end

@implementation NSArray (SSJMagicExportCalendarIndexPath)

- (id)ssj_objectAtCalendarIndexPath:(SSJMagicExportCalendarIndexPath *)indexPath {
    if (self.count <= indexPath.section) {
        SSJPRINT(@"警告：数组越界");
        return nil;
    }
    
    NSArray *subArr1 = [self objectAtIndex:indexPath.section];
    if (![subArr1 isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (subArr1.count <= indexPath.row) {
        SSJPRINT(@"警告：数组越界");
        return nil; 
    }
    
    NSArray *subArr2 = [subArr1 objectAtIndex:indexPath.row];
    if (![subArr2 isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (subArr2.count <= indexPath.index) {
        SSJPRINT(@"警告：数组越界");
        return nil;
    }
    
    return [subArr2 objectAtIndex:indexPath.index];
}

@end
