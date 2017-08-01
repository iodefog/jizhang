//
//  SSJBooksParentSelectCell.h
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJBooksParentSelectCell : SSJBaseTableViewCell


@property(nonatomic, strong) UIImageView *arrowImageView;

- (void)setImage:(NSString *)imageName title:(NSString *)title;

@end
