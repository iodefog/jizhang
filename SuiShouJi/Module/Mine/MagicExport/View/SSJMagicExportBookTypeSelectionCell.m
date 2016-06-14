//
//  SSJMagicExportBookTypeSelectionCell.m
//  SuiShouJi
//
//  Created by old lang on 16/6/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportBookTypeSelectionCell.h"

@interface SSJMagicExportBookTypeSelectionCell ()

@property (nonatomic, strong) UILabel *bookNameLab;

@end

@implementation SSJMagicExportBookTypeSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _bookNameLab = [[UILabel alloc] init];
        _bookNameLab.font = [UIFont systemFontOfSize:14];
        _bookNameLab.textAlignment = NSTextAlignmentCenter;
        _bookNameLab.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [self.contentView addSubview:_bookNameLab];
        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return self;
}

- (void)layoutSubviews {
    _bookNameLab.frame = self.contentView.bounds;
}

- (void)setBookName:(NSString *)bookName {
    _bookNameLab.text = bookName;
}

@end
