//
//  SSJFinancingHomeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeSelectView.h"

@interface SSJFinancingHomeSelectView() <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UIView *titleView;

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation SSJFinancingHomeSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sizeToFit];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        self.layer.mask = self.maskLayer;
    }
    return self;
}

- (void)updateConstraints {
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(6);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(50);
        
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleView).mas_offset(15);
        make.centerY.mas_equalTo(self.titleView.mas_centerY);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self.titleView.mas_bottom);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(220);
    }];
    
    [super updateConstraints];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(260, 316);
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 14)];
        [path addArcWithCenter:CGPointMake(8, 14) radius:8 startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        [path addLineToPoint:CGPointMake(48, 6)];
        [path addLineToPoint:CGPointMake(53, 0)];
        [path addLineToPoint:CGPointMake(60, 6)];
        [path addLineToPoint:CGPointMake(self.width - 8, 6)];
        [path addArcWithCenter:CGPointMake(self.width - 8, 14) radius:8 startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
        [path addLineToPoint:CGPointMake(self.width, self.height - 8)];
        [path addArcWithCenter:CGPointMake(self.width - 8, self.height - 8) radius:8 startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [path addLineToPoint:CGPointMake(8, self.height)];
        [path addArcWithCenter:CGPointMake(8, self.height - 8) radius:8 startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [path addLineToPoint:CGPointMake(0, 14)];
        _maskLayer.path = path.CGPath;
    }
    return _maskLayer;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _titleLab.text = @"选择要统计的资金账户";
    }
    return _titleLab;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
