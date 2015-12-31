//
//  SSJMineHomeTableViewHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"
@interface SSJMineHomeTableViewHeader()


@end

@implementation SSJMineHomeTableViewHeader

+ (id)MineHomeHeader {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJMineHomeTableViewHeader" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    self.portraitButton.layer.cornerRadius = 33;
    self.portraitButton.backgroundColor = [UIColor grayColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
