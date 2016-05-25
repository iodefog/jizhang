//
//  SSJFinancingHomePopView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomePopView.h"
@interface SSJFinancingHomePopView()
@property (weak, nonatomic) IBOutlet UIImageView *backImage;

@end

@implementation SSJFinancingHomePopView

-(void)awakeFromNib{
    self.backImage.image = [UIImage ssj_compatibleImageNamed:@"founds_yindao"];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
