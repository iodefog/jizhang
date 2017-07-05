//
//  SSJFundingTypeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeSelectView.h"
#import "SSJFundingTypeTableViewCell.h"
#import "SSJFundingItem.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJFundingTypeSelectView()
@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *addNewTypeButtonView;
@end
@implementation SSJFundingTypeSelectView{
    NSMutableArray *_items;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sizeToFit];

        [self addSubview:self.tableview];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
//        [self addSubview:self.addNewTypeButtonView];
        self.needCreditOrNot = YES;
        [self addSubview:self.titleView];
    }
    return self;
}      

-(void)layoutSubviews{
    self.titleView.leftTop = CGPointMake(0, 0);
    self.tableview.top = self.titleView.bottom;
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
    self.closeButton.centerY = self.titleView.height / 2;
    self.closeButton.left = 10;
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    [self getDateFromDb];

    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, 245);
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (_dismissBlock) {
            _dismissBlock();
        }
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != [self.tableView numberOfRowsInSection:0]) {
        [self reloadSelectedStatusexceptIndexPath:indexPath];
    }
    if (_fundingTypeSelectBlock) {
        self.fundingTypeSelectBlock(((SSJFundingTypeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).item);
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJFundingTypeCell";
    SSJFundingTypeTableViewCell *FundingTypeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!FundingTypeCell) {
        FundingTypeCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    FundingTypeCell.item = [_items ssj_safeObjectAtIndex:indexPath.row];
    if (!self.selectFundID || self.selectFundID.length == 0) {
        if (indexPath.row == 0) {
            FundingTypeCell.selectedOrNot = YES;
        }else{
            FundingTypeCell.selectedOrNot = NO;
        }
    }else{
        if ([FundingTypeCell.item.fundingID isEqualToString:self.selectFundID]) {
            FundingTypeCell.selectedOrNot = YES;
        }else{
            FundingTypeCell.selectedOrNot = NO; 
        }
    }
    return FundingTypeCell;
}

#pragma mark - getter
-(UITableView *)tableview{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, 200)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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



#pragma mark - private
-(void)closeButtonClicked:(UIButton*)button{
    [self dismiss];
}

-(void)reloadSelectedStatusexceptIndexPath:(NSIndexPath*)selectedIndexpath{
    for (int i = 0; i < [self.tableview numberOfRowsInSection:0]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([indexPath compare:selectedIndexpath] == NSOrderedSame) {
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = YES;
        }else{
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = NO;
        }
    }
}

-(void)getDateFromDb{
    [_items removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        FMResultSet * rs = [db executeQuery:@"select a.* from bk_fund_info  a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? and a.cparent <> 11 and a.cparent <> 10 order by a.iorder",SSJUSERID()];
        _items = [[NSMutableArray alloc]init];
        while ([rs next]) {
            SSJFundingItem *item = [[SSJFundingItem alloc]init];
            item.fundingColor = [rs stringForColumn:@"CCOLOR"];
            item.fundingIcon = [rs stringForColumn:@"CICOIN"];
            item.fundingID = [rs stringForColumn:@"CFUNDID"];
            item.fundingName = [rs stringForColumn:@"CACCTNAME"];
            item.fundingParent = [rs stringForColumn:@"CPARENT"];
            if (!(!self.needCreditOrNot && ([item.fundingParent isEqualToString:@"3"] || [item.fundingParent isEqualToString:@"16"]))) {
                [_items addObject:item];
            }
        }
        SSJFundingItem *item = [[SSJFundingItem alloc]init];
        item.fundingName = @"添加新的资金账户";
        item.fundingIcon = @"add";
        [_items addObject:item];
        SSJDispatch_main_async_safe(^(){
            [weakSelf.tableView reloadData];
        });
    }];
}
    
- (void)setNeedCreditOrNot:(BOOL)needCreditOrNot {
    _needCreditOrNot = needCreditOrNot;
}

-(void)reloadDate{
    [self getDateFromDb];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
