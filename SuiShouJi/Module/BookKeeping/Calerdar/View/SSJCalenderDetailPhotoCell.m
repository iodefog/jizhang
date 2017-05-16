//
//  SSJCalenderDetailPhotoCell.m
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailPhotoCell.h"

@interface SSJCalenderDetailPhotoCell ()

@property (nonatomic, strong) UIImageView *photo;

@end

@implementation SSJCalenderDetailPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.photo = [[UIImageView alloc] init];
        [self.contentView addSubview:self.photo];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseItem *)cellItem {
    [super setCellItem:cellItem];
}

@end
