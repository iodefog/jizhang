//
//  SSJCalendarTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 15/12/24.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarTableViewCell.h"
@interface SSJCalendarTableViewCell()
@property (nonatomic,strong) UIImageView *fundingImage;
@property (nonatomic,strong) UIImageView *checkMark;
@end
@implementation SSJCalendarTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
