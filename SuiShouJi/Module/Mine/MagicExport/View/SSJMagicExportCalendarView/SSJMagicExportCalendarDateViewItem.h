//
//  SSJMagicExportCalendarViewCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportCalendarDateViewItem : NSObject

@property (nonatomic) BOOL hidden;

@property (nonatomic) BOOL selected;

@property (nonatomic) BOOL showMarker;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, strong) UIColor *dateColor;

@property (nonatomic, strong) UIColor *selectedDateColor;

@property (nonatomic, strong) UIColor *highlightColor;

@end
