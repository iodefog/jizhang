//
//  SSJReportFormsScaleAxisCell.h
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsScaleAxisCellItem;

@interface SSJReportFormsScaleAxisCell : UICollectionViewCell

@property (nonatomic, strong) SSJReportFormsScaleAxisCellItem *item;

@end

@interface SSJReportFormsScaleAxisCellItem : NSObject

@property (nonatomic, copy) NSString *scaleValue;

@property (nonatomic, strong) UIColor *scaleColor;

@property (nonatomic) CGFloat scaleHeight;

@property (nonatomic) BOOL scaleMarkShowed;

@end
