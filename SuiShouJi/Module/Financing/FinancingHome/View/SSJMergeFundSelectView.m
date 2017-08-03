//
//  SSJMergeFundSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMergeFundSelectView.h"
#import "SSJBaseTableViewCell.h"
#import "SSJCreditCardItem.h"

static NSString *cellId = @"SSJFundingTypeCell";

@interface SSJMergeFundSelectView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *titleView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) SSJBaseCellItem *selectItem;

@property (nonatomic, strong) UIImageView *accessoryView;

@end

@implementation SSJMergeFundSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sizeToFit];
        
        [self addSubview:self.tableView];
        [self addSubview:self.titleView];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        [self layoutIfNeeded];
    }
    return self;
}

-(void)layoutSubviews{
    self.titleView.leftTop = CGPointMake(0, 0);
    self.tableView.top = self.titleView.bottom;
    self.tableView.size = CGSizeMake(self.width, self.height - self.titleView.height);
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
    self.closeButton.centerY = self.titleView.height / 2;
    self.closeButton.left = 10;
}

- (void)showWithSelectedItem:(SSJBaseCellItem *)item {
    if (self.superview) {
        return;
    }
    
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;

    self.selectItem = item;
    
    [self.tableView reloadData];
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJFinancingHomeitem *item = [self.fundsArr ssj_safeObjectAtIndex:indexPath.row];
    
    if (self.didSelectFundItem) {
        self.didSelectFundItem(item,item.fundingParent);
    }
    
    [self dismiss];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fundsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectFundid;
    
    NSString *selectParent;

    if ([self.selectItem isKindOfClass:[SSJFinancingHomeitem class]]) {
        selectFundid = ((SSJFinancingHomeitem *)self.selectItem).fundingID;
    } else if ([self.selectItem isKindOfClass:[SSJCreditCardItem class]]) {
        selectFundid = ((SSJCreditCardItem *)self.selectItem).cardId;
    }
    
    SSJFinancingHomeitem *item = [self.fundsArr ssj_safeObjectAtIndex:indexPath.row];
    
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.imageView.image = [[UIImage imageNamed:item.fundingIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    cell.imageView.tintColor = [UIColor ssj_colorWithHex:item.fundingColor];
    
    cell.textLabel.text = item.fundingName;
    
    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    self.accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    cell.accessoryView = [item.fundingID isEqualToString:selectFundid] ? self.accessoryView : nil;
    
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.rowHeight = 55;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

-(UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45)];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"选择资金账户";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_titleView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_titleView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_titleView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_closeButton];
        _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _titleView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _accessoryView;
}

#pragma mark - private
-(void)closeButtonClicked:(UIButton*)button{
    [self dismiss];
}

- (void)setFundsArr:(NSArray *)fundsArr {
    _fundsArr = fundsArr;
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
