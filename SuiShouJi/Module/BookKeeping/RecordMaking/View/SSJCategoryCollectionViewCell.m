//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"

@interface SSJCategoryCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end
@implementation SSJCategoryCollectionViewCell

- (void)awakeFromNib {
    self.categoryImage.layer.cornerRadius = 20;
    self.categoryImage.layer.masksToBounds = YES;
    self.editButton.layer.cornerRadius = 6.f;
    self.editButton.layer.masksToBounds = YES;
    self.editButton.hidden = NO;
    [self.editButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setEditeModel:(BOOL)EditeModel{
    _EditeModel = EditeModel;
    if (_EditeModel == YES) {
        self.editButton.hidden = NO;
    }else if (_EditeModel == NO){
        self.editButton.hidden = YES;
    }
}

-(void)removeButtonClicked:(UIButton*)button{
    NSLog(@"remove");
}
@end
