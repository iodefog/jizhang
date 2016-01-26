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
        [self getDateFromDb];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:self.tableview];
//        [self addSubview:self.addNewTypeButtonView];
        [self addSubview:self.titleView];
    }
    return self;
}

-(void)layoutSubviews{
    self.tableview.bottom = self.height;
    self.titleView.bottom = self.tableview.top;
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
    self.closeButton.centerY = self.titleView.height / 2;
    self.closeButton.left = 10;
//    self.addNewTypeButton.center = CGPointMake(self.width / 2, self.height / 2);
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reloadSelectedStatusexceptIndexPath:indexPath];
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
    FundingTypeCell.item = [_items objectAtIndex:indexPath.row];
    return FundingTypeCell;
}

#pragma mark - getter
-(UITableView *)tableview{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, 200)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

-(UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"选择资金账户";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_titleView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_titleView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_titleView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_closeButton];
    }
    return _titleView;
}


#pragma mark - private
-(void)closeButtonClicked:(UIButton*)button{
    [self removeFromSuperview];
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
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE A.CPARENT != 'root' AND A.CFUNDID = B.CFUNDID AND A.OPERATORTYPE <> 2 AND A.CUSERID = ?",SSJUSERID()];
    _items = [[NSMutableArray alloc]init];
    while ([rs next]) {
        SSJFundingItem *item = [[SSJFundingItem alloc]init];
        item.fundingColor = [rs stringForColumn:@"CCOLOR"];
        item.fundingIcon = [rs stringForColumn:@"CICOIN"];
        item.fundingID = [rs stringForColumn:@"CFUNDID"];
        item.fundingName = [rs stringForColumn:@"CACCTNAME"];
        item.fundingParent = [rs stringForColumn:@"CPARENT"];
        item.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
        [_items addObject:item];
    }
    SSJFundingItem *item = [[SSJFundingItem alloc]init];
    item.fundingName = @"添加资金新的账户";
    item.fundingIcon = @"add";
    [_items addObject:item];
    [self.tableView reloadData];
}

-(void)reloadDate{
    [self getDateFromDb];
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
