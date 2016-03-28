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
    self.headPotraitImage.layer.cornerRadius = 33;
    self.headPotraitImage.layer.masksToBounds = YES;
    self.headPotraitImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headPotraitImage.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
    self.headPotraitImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loginButtonClicked:)];
    [self.headPotraitImage addGestureRecognizer:singleTap];
    UITapGestureRecognizer *backsingleTap =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backsingleTap:)];
    [self addGestureRecognizer:backsingleTap];
}

- (void)loginButtonClicked:(id)sender {
    if (self.HeaderButtonClickedBlock) {
        self.HeaderButtonClickedBlock();
    }
}

-(void)backsingleTap:(id)sender{
    if (self.HeaderClickedBlock) {
        self.HeaderClickedBlock();
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
