//
//  SSJBookKeepingRiminderCircleView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingRiminderCircleView.h"
#import "SSJFundingTypeTableViewCell.h"
#import "SSJBookkeepingRiminderCell.h"

@interface SSJBookKeepingRiminderCircleView()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@end
@implementation SSJBookKeepingRiminderCircleView{
    NSArray *_weekdayArray;
    NSMutableArray *_selectWeekdayArray;
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:self.tableView];
        [self addSubview:self.topView];

#warning test
        self.selectWeekStr = @"1,2,3,4,5,6,7";
        _weekdayArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
        _selectWeekdayArray = [[NSMutableArray alloc]initWithArray:[self.selectWeekStr componentsSeparatedByString:@","]];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.bottom = self.height;
    self.tableView.size = CGSizeMake(self.width, 320);
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftBottom = CGPointMake(0, self.tableView.top);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 40;
    self.comfirmButton.size = CGSizeMake(40, 40);
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFundingTypeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectedOrNot) {
        [_selectWeekdayArray removeObject:[NSString stringWithFormat:@"%ld",indexPath.row + 1]];
    }else{
        [_selectWeekdayArray addObject:[NSString stringWithFormat:@"%ld",indexPath.row + 1]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _weekdayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJRiminderCircleCell";
    SSJFundingTypeTableViewCell *RiminderCircleCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!RiminderCircleCell) {
        RiminderCircleCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([_selectWeekdayArray containsObject:[NSString stringWithFormat:@"%ld",indexPath.row + 1]]) {
        RiminderCircleCell.selectedOrNot = YES;
    }else{
        RiminderCircleCell.selectedOrNot = NO;
    }
    RiminderCircleCell.cellTitle = [_weekdayArray ssj_safeObjectAtIndex:indexPath.row];
    return RiminderCircleCell;
}


-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"重复";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_closeButton];
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_comfirmButton];
    }
    return _topView;
}

-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, 320)];
        _tableView.separatorStyle = UITableViewCellSelectionStyleGray;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

-(void)closeButtonClicked:(id)sender{
    [self removeFromSuperview];
}

-(void)comfirmButtonClicked:(id)sender{
    NSArray *tempArr =  [_selectWeekdayArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 intValue] > [obj2 intValue]){
            return NSOrderedDescending;
        }
        if ([obj1 intValue] < [obj2 intValue]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    NSString *dateNumString = [tempArr componentsJoinedByString:@","];
    NSString *dateString;
    if (tempArr.count == 7) {
        dateString = @"每天";
    }else if (tempArr.count == 5 && ![tempArr containsObject:@"1"] &&  ![tempArr containsObject:@"7" ]){
        dateString = @"每个工作日";
    }else if (tempArr.count == 2 && [tempArr containsObject:@"1"] &&  [tempArr containsObject:@"7" ]){
        dateString = @"每个周末";
    }else{
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0; i < tempArr.count; i ++) {
            NSInteger date = [[tempArr objectAtIndex:i] intValue];
            switch (date) {
                case 1:
                    [array addObject:@"周日"];
                    break;
                case 2:
                    [array addObject:@"周一"];
                    break;
                case 3:
                    [array addObject:@"周二"];
                    break;
                case 4:
                    [array addObject:@"周三"];
                    break;
                case 5:
                    [array addObject:@"周四"];
                    break;
                case 6:
                    [array addObject:@"周五"];
                    break;
                case 7:
                    [array addObject:@"周六"];
                    break;
                default:
                    break;
            }
        }
        dateString = [array componentsJoinedByString:@","];
    }
    if (self.circleSelectBlock) {
        self.circleSelectBlock(dateNumString,dateString);
    }
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
