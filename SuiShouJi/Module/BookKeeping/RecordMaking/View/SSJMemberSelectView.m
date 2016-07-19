//
//  SSJMemberSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberSelectView.h"
#import "SSJBaseTableViewCell.h"
#import "SSJChargeMemberItem.h"
#import "SSJDatabaseQueue.h"

@interface SSJMemberSelectView()

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) UIImageView *accessoryView;

@end

@implementation SSJMemberSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        [self addSubview:self.tableView];
    }
    return self;
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJChargeMemberItem *item = [self.items objectAtIndex:indexPath.row];
    if (indexPath.row != [tableView numberOfRowsInSection:0] - 1) {
        if ([self.selectedMembers containsObject:item.memberId]) {
            [self.selectedMembers removeObject:item.memberId];
        }else{
            [self.selectedMembers addObject:item.memberId];
        }
        [self.tableView reloadData];
    }else{
        
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMemberCell";
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    SSJChargeMemberItem *item = [self.items objectAtIndex:indexPath.row];
    NSString *title = item.memberName;
    NSString *memberId = item.memberId;
    cell.textLabel.text = title;
    cell.accessoryView = [self.selectedMembers containsObject:memberId] ? self.accessoryView : nil;
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        
        [_tableView ssj_setBorderWidth:2];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
    }
    return _tableView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _accessoryView;
}

#pragma mark - Private
- (void)show {
    if (self.superview) {
        return;
    }
    [self getDataFromDb];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
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
        if (_dismissBlock) {
            _dismissBlock();
        }
    }];
}

-(void)getDataFromDb{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select * from bk"];
        NSMutableArray *tempArr = [NSMutableArray array];
        while ([result next]) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberName = [result stringForColumn:@""];
            item.memberId = [result stringForColumn:@""];
            [tempArr addObject:item];
        }
        self.items = [NSArray arrayWithArray:tempArr];
        [weakSelf.tableView reloadData];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
