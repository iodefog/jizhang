//
//  SSJFundingTypeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeSelectView.h"
#import "SSJFundingTypeTableViewCell.h"

@interface SSJFundingTypeSelectView()
@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *addNewTypeButton;
@property (nonatomic,strong) UIView *addNewTypeButtonView;
@end
@implementation SSJFundingTypeSelectView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:self.tableview];
//        [self addSubview:self.addNewTypeButtonView];
        [self addSubview:self.titleView];
    }
    return self;
}

-(void)layoutSubviews{
    self.tableview.bottom = self.height;
    self.addNewTypeButton.center = CGPointMake(self.addNewTypeButtonView.width / 2, self.addNewTypeButtonView.height / 2);
    self.addNewTypeButtonView.bottom = self.height;
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return nil;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 187;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reloadSelectedStatusexceptIndexPath:indexPath];
    if (_fundingTypeSelectBlock) {
        self.fundingTypeSelectBlock(((SSJFundingTypeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).fundingTitle.text);
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJFundingTypeCell";
    SSJFundingTypeTableViewCell *FundingTypeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!FundingTypeCell) {
        FundingTypeCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
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
        [_closeButton setImage:[UIImage imageNamed:@"closebutton test"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_closeButton];
    }
    return _titleView;
}

-(UIView*)addNewTypeButtonView{
    if (_addNewTypeButtonView == nil) {
        _addNewTypeButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 200)];
        _addNewTypeButtonView.backgroundColor = [UIColor whiteColor];
        _addNewTypeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 230, 75)];
        [_addNewTypeButton setTitle:@"添加新的资金账户" forState:UIControlStateNormal];
        [_addNewTypeButton setTitleColor:[UIColor ssj_colorWithHex:@"a7a7a7"] forState:UIControlStateNormal];
        _addNewTypeButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _addNewTypeButton.backgroundColor = [UIColor whiteColor];
        _addNewTypeButton.layer.cornerRadius = 3;
        _addNewTypeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"a7a7a7"].CGColor;
        _addNewTypeButton.layer.borderWidth = 1;
        [_addNewTypeButtonView addSubview:_addNewTypeButton];
    }
    return _addNewTypeButtonView;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
