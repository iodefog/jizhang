//
//  calendarView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarView.h"
#import "SSJCalendarCollectionViewCell.h"

@interface SSJCalendarView()
@property(nonatomic)long year;
@property(nonatomic)long month;
@end

@implementation SSJCalendarView{
    CGFloat _marginForHorizon;
    CGFloat _marginForvertical;
    NSArray *_weekArray;
}
#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _marginForHorizon = (self.width - 35*7) / 9;
        _marginForvertical = (self.height - 35*7) / 14;
        _weekArray = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六",  nil];
        [self addSubview:self.calendar];
        [self.calendar registerClass:[SSJCalendarCollectionViewCell class] forCellWithReuseIdentifier:@"NormalCell"];
    }
    return self;
}

-(void)layoutSubviews{
    self.calendar.frame = CGRectMake(0, 0, self.width, self.height);
}

-(void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    [self getYearAndMonth];
}
#pragma mark - Getter
- (UICollectionView *)calendar{
    if (_calendar == nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = _marginForHorizon;
        _calendar =[[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _calendar.backgroundColor=[UIColor whiteColor];
        _calendar.dataSource=self;
        _calendar.delegate=self;
        _calendar.allowsMultipleSelection = NO;
    }
    return _calendar;
}

#pragma mark - UICollectionViewDataSource
//返回section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回section中的cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%ld",[self getDaysOfMonth:self.year withMonth:self.month] + [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month]);
    return 49;

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(_marginForvertical,_marginForHorizon,_marginForvertical,_marginForHorizon);
}


//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 7) {
        SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
        cell.currentDay = [_weekArray objectAtIndex:indexPath.row];
        cell.userInteractionEnabled = NO;
        cell.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        return cell;
    }
    if (indexPath.row < [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + 7 - 1) {
        SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
        cell.currentDay = [[NSString alloc] initWithFormat:@"%ld",[self getDaysOfMonth:self.year withMonth:self.month - 1] - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + indexPath.row - 5] ;
        cell.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        cell.userInteractionEnabled = NO;
        cell.isSelected = NO;
        return cell;
    }else{
        if (indexPath.row > [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + [self getDaysOfMonth:self.year withMonth:self.month] + 5) {
            SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
            cell.currentDay = [[NSString alloc] initWithFormat:@"%ld",indexPath.row - [self getDaysOfMonth:self.year withMonth:self.month] - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] - 5] ;
            cell.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
            cell.userInteractionEnabled = NO;
            return cell;
        }
       SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
        cell.currentDay = [[NSString alloc] initWithFormat:@"%ld",indexPath.row - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] - 5];
        cell.isSelected = NO;
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
//返回cell的宽和高
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(36, 36);
}

//每行cell之间的间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _marginForvertical;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCalendarCollectionViewCell *cell = (SSJCalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isSelected == NO) {
        for (int i = 0; i < [collectionView.visibleCells count]; i++) {
            ((SSJCalendarCollectionViewCell*)[collectionView.visibleCells objectAtIndex:i]).isSelected = NO;
        }
        cell.isSelected = YES;
    }else{
        for (int i = 0; i < [collectionView.visibleCells count]; i++) {
            ((SSJCalendarCollectionViewCell*)[collectionView.visibleCells objectAtIndex:i]).isSelected = NO;
        }
    }

}

#pragma mark - Private
//得到当前的年份和月份
-(void)getYearAndMonth{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit;
    comps = [calendar components:unitFlags fromDate:self.currentDate];
    self.year = [comps year];
    self.month = [comps month];
}

//获得某个月的第一天是星期几
-(long)getWeekOfFirstDayOfMonth:(long)year withMonth:(long)month{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSString *firstWeekDayMonth = [[NSString alloc] initWithFormat:@"%ld",year];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%ld",month]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%d",1]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *weekOfFirstDayOfMonth = [dateFormatter dateFromString:firstWeekDayMonth];
    NSDateComponents *newCom = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:weekOfFirstDayOfMonth];
    return [newCom weekday];
}

//返回一个月有多少天
-(long)getDaysOfMonth:(long)year withMonth:(long)month{
    NSInteger days = 0;
    //1,3,5,7,8,10,12
    NSArray *bigMoth = [[NSArray alloc] initWithObjects:@"1",@"3",@"5",@"7",@"8",@"10",@"12", nil];
    //4,6,9,11
    NSArray *milMoth = [[NSArray alloc] initWithObjects:@"4",@"6",@"9",@"11", nil];
    if ([bigMoth containsObject:[[NSString alloc] initWithFormat:@"%ld",(long)month]]) {
        days = 31;
    }else if([milMoth containsObject:[[NSString alloc] initWithFormat:@"%ld",(long)month]]){
        days = 30;
    }else{
        if ([self isLoopYear:year]) {
            days = 29;
        }else
            days = 28;
    }
    return days;
}

//判断是否是闰年
-(BOOL)isLoopYear:(NSInteger)year{
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return true;
    }else
        return NO;
}

//返回日历高度
- (CGFloat)viewHeight{

    return 315;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
