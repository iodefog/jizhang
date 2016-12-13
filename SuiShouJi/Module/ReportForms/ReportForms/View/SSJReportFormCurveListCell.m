//
//  SSJReportFormCurveListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveListCell.h"

@interface SSJReportFormCurveListCell ()

//@property (nonatomic, strong) UILabel *

@end

@implementation SSJReportFormCurveListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        return;
    }
    
    
}

@end
