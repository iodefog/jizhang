//
//  SSJBooksSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksSelectView.h"
#import "SSJBaseTableViewCell.h"

static NSString *kCellID = @"cellID";

@interface SSJBooksSelectView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *accessoryView;

@property (nonatomic, strong) UIView *seperatorView;

@property (nonatomic, strong) SSJBaseCellItem <SSJBooksItemProtocol> *selectItem;

@end

@implementation SSJBooksSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self addSubview:self.titleLab];
        [self addSubview:self.seperatorView];
        self.layer.cornerRadius = 12;
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(280, 275);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.layer ssj_relayoutBorder];
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(20);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(55);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.seperatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    [super updateConstraints];
}

- (void)showWithSelectedItem:(SSJBaseCellItem <SSJBooksItemProtocol> *)item {
    if (self.superview) {
        return;
    }
    
    self.selectItem = item;
    
    [self sizeToFit];
    
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    
    self.centerX = keyWindow.centerX;
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.center = keyWindow.center;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.text = @"选择账本";
    }
    return _titleLab;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.rowHeight = 55;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (UIView *)seperatorView {
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _seperatorView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _accessoryView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _booksItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem <SSJBooksItemProtocol> *item = [_booksItems objectAtIndex:indexPath.row];
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    cell.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    
    cell.textLabel.text = item.booksName;
    
    cell.accessoryView = [item.booksId isEqualToString:self.selectItem.booksId] ? self.accessoryView : nil;
    
    self.accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJBaseCellItem <SSJBooksItemProtocol> *item = [_booksItems objectAtIndex:indexPath.row];
    self.selectItem = item;
    if (self.booksTypeSelectBlock) {
        self.booksTypeSelectBlock(item);
    }
    [self dismiss];
    [self.tableView reloadData];
}

- (void)setBooksItems:(NSArray<SSJBooksItemProtocol> *)booksItems {
    _booksItems = booksItems;
    [self setNeedsUpdateConstraints];
    [self.tableView reloadData];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
