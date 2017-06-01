//
//  SSJMagicExportCalendarDateView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJMagicExportCalendarDateView;
@class SSJMagicExportCalendarDateViewItem;

@interface SSJMagicExportCalendarDateView : UIView

@property (nonatomic, strong) SSJMagicExportCalendarDateViewItem *item;

@property (nonatomic, copy) void(^clickBlock)(SSJMagicExportCalendarDateView *);

@end



@interface SSJMagicExportCalendarDateViewItem : NSObject

@property (nonatomic) BOOL hidden;

@property (nonatomic) BOOL showMarker;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, strong) UIColor *dateColor;

@property (nonatomic, strong) UIColor *markerColor;

@property (nonatomic, strong) UIColor *descColor;

@property (nonatomic, strong) UIColor *fillColor;

@end
