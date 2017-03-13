//
//  SSJBookKeepingHomeNoDataCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeNoDataCell.h"
#import "SSJBookKeepingHomeNoDataHeader.h"

@interface SSJBookKeepingHomeNoDataCell()

@property(nonatomic, strong) SSJBookKeepingHomeNoDataHeader *noDataView;

@end

@implementation SSJBookKeepingHomeNoDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.noDataView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.noDataView.size = self.size;
}

- (SSJBookKeepingHomeNoDataHeader *)noDataView {
    if (!_noDataView) {
        _noDataView = [[SSJBookKeepingHomeNoDataHeader alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }
    return _noDataView;
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.backgroundColor = [UIColor clearColor];
    [self.noDataView updateAfterThemeChanged];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
