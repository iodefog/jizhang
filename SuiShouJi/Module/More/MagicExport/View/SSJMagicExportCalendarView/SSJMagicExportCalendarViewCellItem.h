//
//  SSJMagicExportCalendarViewCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportCalendarViewCellItem : NSObject

@property (nonatomic) BOOL selected;

@property (nonatomic) BOOL showMarker;

@property (nonatomic) BOOL showContent;

@property (nonatomic) BOOL canSelect;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) UIColor *desc;

@end
