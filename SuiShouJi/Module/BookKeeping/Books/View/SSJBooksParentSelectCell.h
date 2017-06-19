//
//  SSJBooksParentSelectCell.h
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBooksParentSelectCell : UITableViewCell


@property(nonatomic, strong) UIImageView *arrowImageView;

- (void)setImage:(NSString *)imageName title:(NSString *)title;

@end
