//
//  SSJRecordMakingBillTypeSelectionCellLabel.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/5/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecordMakingBillTypeSelectionCellLabel : UIView

@property (nonatomic, strong, readonly) CATextLayer *textLayer;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIColor *textColor;

@end
