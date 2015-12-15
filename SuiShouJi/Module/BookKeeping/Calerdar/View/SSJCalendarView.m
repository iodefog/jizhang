//
//  calendarView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarView.h"
#import "SSJCalendarNIlCollectionViewCell.h"
#import "SSJCalendarCollectionViewCell.h"

@interface SSJCalendarView()
@property(nonatomic)int year;
@property(nonatomic)int month;
@end

@implementation SSJCalendarView
#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.calendar];
        [self getYearAndMonth];
        [self.calendar registerClass:[SSJCalendarCollectionViewCell class] forCellWithReuseIdentifier:@"NormalCell"];
        [self.calendar registerClass:[SSJCalendarNIlCollectionViewCell class] forCellWithReuseIdentifier:@"NilCell"];
    }
    return self;
}

#pragma mark - Getter
- (UICollectionView *)calendar{
    if (_calendar==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.headerReferenceSize=CGSizeMake(self.width, 7);
        _calendar =[[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _calendar.backgroundColor=[UIColor groupTableViewBackgroundColor];
        _calendar.dataSource=self;
        _calendar.delegate=self;
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
    return [self getDaysOfMonth:self.year withMonth:self.month] + [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month];
}

//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month]) {
        SSJCalendarNIlCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellNil" forIndexPath:indexPath];
        return cell;
    }else{
       SSJCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalCell" forIndexPath:indexPath];
        cell.currentDay = [[NSString alloc] initWithFormat:@"%d",indexPath.row - [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month] + 1];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
//返回cell的宽和高
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellWidth = self.width / 7;
    CGFloat cellHight = 40;
    return CGSizeMake(cellWidth, cellHight);
}

//每行cell之间的间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//返回头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
        return nil;
}

#pragma mark - Private
//得到当前的年份和月份
-(void)getYearAndMonth{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit;
    comps = [calendar components:unitFlags fromDate:self.currentNSDate];
    self.year = [comps year];
    self.month = [comps month];
}

//获得某个月的第一天是星期几
-(int)getWeekOfFirstDayOfMonth:(int)year withMonth:(int)month{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSString *firstWeekDayMonth = [[NSString alloc] initWithFormat:@"%d",year];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%d",month]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%s","-"]];
    firstWeekDayMonth = [firstWeekDayMonth stringByAppendingString:[[NSString alloc]initWithFormat:@"%d",1]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *weekOfFirstDayOfMonth = [dateFormatter dateFromString:firstWeekDayMonth];
    NSDateComponents *newCom = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:weekOfFirstDayOfMonth];
    return [newCom weekday];
}

//返回一个月有多少天
-(int)getDaysOfMonth:(int)year withMonth:(int)month{
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
    return ([self getDaysOfMonth:self.year withMonth:self.month] + [self getWeekOfFirstDayOfMonth:self.year withMonth:self.month])/7*40;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
