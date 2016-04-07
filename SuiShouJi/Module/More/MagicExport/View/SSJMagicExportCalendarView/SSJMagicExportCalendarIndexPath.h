//
//  SSJMagicExportCalendarViewIndexPath.h
//  SuiShouJi
//
//  Created by old lang on 16/4/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJMagicExportCalendarIndexPath : NSObject

@property (nonatomic, assign, readonly) NSInteger section;

@property (nonatomic, assign, readonly) NSInteger row;

@property (nonatomic, assign, readonly) NSInteger index;

+ (instancetype)indexPathForSection:(NSInteger)sectioin row:(NSInteger)row index:(NSInteger)index;

@end


@interface NSArray (SSJMagicExportCalendarIndexPath)

- (id)ssj_objectAtCalendarIndexPath:(SSJMagicExportCalendarIndexPath *)indexPath;

@end