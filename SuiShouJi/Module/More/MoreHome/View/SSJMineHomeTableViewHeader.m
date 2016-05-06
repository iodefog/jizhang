//
//  SSJMineHomeTableViewHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"

@interface SSJMineHomeTableViewHeader()
@property (weak, nonatomic) IBOutlet SSJMineHeaderView *headPotraitImage;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property(nonatomic, strong) UIButton *checkInButton;
@property(nonatomic, strong) UIButton *syncButton;
@end

@implementation SSJMineHomeTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib{
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
