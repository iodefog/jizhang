//
//  SSJFinancingHomeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeSelectView.h"
#import "SSJFundingHomeSelectCell.h"
#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"

static const NSTimeInterval kDuration = 0.2;

static const CGFloat kGap = 40;

static const CGFloat kTriangleHeight = 6;

static const CGFloat kCornerRadius = 8;

static NSString *const SSJFundingHomeSelectCellIndetifer = @"SSJFundingHomeSelectCellIndetifer";

@interface SSJFinancingHomeSelectView() <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UIView *titleView;

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) CAShapeLayer *maskLayer;

@property(nonatomic) CGPoint point;

@property(nonatomic, strong) NSString *selectedFundid;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) NSMutableArray *selectedFundids;

@end

@implementation SSJFinancingHomeSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sizeToFit];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        self.layer.mask = self.maskLayer;
        [self addSubview:self.titleView];
        [self addSubview:self.titleLab];
        [self addSubview:self.tableView];
        [self updateConstraintsIfNeeded];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
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
        [path moveToPoint:CGPointMake(0, kTriangleHeight + kCornerRadius)];
        [path addArcWithCenter:CGPointMake(kCornerRadius, kTriangleHeight + kCornerRadius) radius:kCornerRadius startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
        [path addLineToPoint:CGPointMake(kGap + kCornerRadius, kTriangleHeight)];
        [path addLineToPoint:CGPointMake(kGap + kCornerRadius + kCornerRadius, 0)];
        [path addLineToPoint:CGPointMake(60, kTriangleHeight)];
        [path addLineToPoint:CGPointMake(self.width - kCornerRadius, kTriangleHeight)];
        [path addArcWithCenter:CGPointMake(self.width - kCornerRadius, kTriangleHeight + kCornerRadius) radius:kCornerRadius startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
        [path addLineToPoint:CGPointMake(self.width, self.height - kCornerRadius)];
        [path addArcWithCenter:CGPointMake(self.width - kCornerRadius, self.height - 8) radius:kCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [path addLineToPoint:CGPointMake(kCornerRadius, self.height)];
        [path addArcWithCenter:CGPointMake(kCornerRadius, self.height - kCornerRadius) radius:kCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [path addLineToPoint:CGPointMake(0, kTriangleHeight + kCornerRadius)];
        _maskLayer.path = path.CGPath;
    }
    return _maskLayer;
}


#pragma mark - Getter
- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
    }
    return _titleView;
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
        [_tableView registerClass:[SSJFundingHomeSelectCell class] forCellReuseIdentifier:SSJFundingHomeSelectCellIndetifer];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fundId;
    
    if ([[self.items ssj_safeObjectAtIndex:indexPath.row] isKindOfClass:[SSJFinancingHomeitem class]]) {
        fundId = ((SSJFinancingHomeitem *)[self.items ssj_safeObjectAtIndex:indexPath.row]).fundingID;
    } else if (([[self.items ssj_safeObjectAtIndex:indexPath.row] isKindOfClass:[SSJCreditCardItem class]])) {
        fundId = ((SSJCreditCardItem *)[self.items ssj_safeObjectAtIndex:indexPath.row]).cardId;
    }
    
    SSJFinancingHomeitem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    
    SSJFundingHomeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:SSJFundingHomeSelectCellIndetifer];
    
    BOOL selectAll = [self.selectedFundid isEqualToString:@"all"];
    
    if (selectAll) {
        cell.isSelected = YES;
    } else {
        cell.isSelected = [self.selectedFundids containsObject:fundId];
    }
    
    cell.item = item;
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fundId;
    
    if ([[self.items ssj_safeObjectAtIndex:indexPath.row] isKindOfClass:[SSJFinancingHomeitem class]]) {
        fundId = ((SSJFinancingHomeitem *)[self.items ssj_safeObjectAtIndex:indexPath.row]).fundingID;
    } else if (([[self.items ssj_safeObjectAtIndex:indexPath.row] isKindOfClass:[SSJCreditCardItem class]])) {
        fundId = ((SSJCreditCardItem *)[self.items ssj_safeObjectAtIndex:indexPath.row]).cardId;
    }
    
    if (indexPath.row == 0) {
        if ([self.selectedFundid isEqualToString:@"all"]) {
            [self.selectedFundids removeAllObjects];
            self.selectedFundid = @"";
        } else {
            [self getAllFundIds];
        }
    } else {
        if ([self.selectedFundids containsObject:fundId]) {
            [self.selectedFundids removeObject:fundId];
        } else {
            [self.selectedFundids addObject:fundId];
        }
        if (self.selectedFundids.count == self.items.count - 1) {
            self.selectedFundid = @"all";
        } else {
            self.selectedFundid = [self.selectedFundids componentsJoinedByString:@","];
        }

    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Event
- (void)dismiss {
    if (self.superview) {
        self.tableView.alpha = 0;
        
        [self.superview ssj_hideBackViewForView:self animation:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.left = self.point.x - kGap;
            self.top = self.point.y;
        } timeInterval:kDuration fininshed:^(BOOL complation) {
            self.transform = CGAffineTransformIdentity;
            if (self.dismissBlock) {
                self.dismissBlock(self.selectedFundid, self.selectedFundids);
            }
        }];
    }

}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point {
    if (!self.superview) {
        _tableView.alpha = 0;
        
        self.point = point;
        
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        
        [window ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.5 target:self touchAction:@selector(tapBackgroundViewAction) animation:^{
            
            self.transform = CGAffineTransformIdentity;
            self.left = self.point.x - kGap - 7;
            self.top = self.point.y;
        } timeInterval:kDuration fininshed:^(BOOL finished) {
            [_tableView reloadData];
            [UIView animateWithDuration:kDuration animations:^{
                _tableView.alpha = 1;
            }];
        }];
        
    }
}

- (void)tapBackgroundViewAction {
    [self dismiss];
}

- (void)updateCellAppearanceAfterThemeChanged {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

- (void)setItems:(NSMutableArray *)items andSelectFundid:(NSString *)fundids {
    _items = [NSMutableArray arrayWithArray:items];
    
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
    item.fundingName = @"全选";
    [_items insertObject:item atIndex:0];
    
    _selectedFundid = fundids;
    if (![fundids isEqualToString:@"all"]) {
        _selectedFundids = [NSMutableArray arrayWithArray:[fundids componentsSeparatedByString:@","]];
    } else {
        [self getAllFundIds];
    }
}

- (void)getAllFundIds {
    self.selectedFundids = [NSMutableArray arrayWithCapacity:0];
    
    [_items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fundId;
        
        if (idx != 0) {
            if ([[self.items ssj_safeObjectAtIndex:idx] isKindOfClass:[SSJFinancingHomeitem class]]) {
                fundId = ((SSJFinancingHomeitem *)[_items ssj_safeObjectAtIndex:idx]).fundingID;
            } else if (([[self.items ssj_safeObjectAtIndex:idx] isKindOfClass:[SSJCreditCardItem class]])) {
                fundId = ((SSJCreditCardItem *)[_items ssj_safeObjectAtIndex:idx]).cardId;
            }
            [self.selectedFundids addObject:fundId];
        }
    }];
    
    self.selectedFundid = @"all";

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
