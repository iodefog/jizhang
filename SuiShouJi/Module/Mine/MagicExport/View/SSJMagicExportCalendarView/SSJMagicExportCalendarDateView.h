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

@property (nonatomic, copy) BOOL(^shouldSelectBlock)(SSJMagicExportCalendarDateView *);

@property (nonatomic, copy) void(^didSelectBlock)(SSJMagicExportCalendarDateView *);

@end
