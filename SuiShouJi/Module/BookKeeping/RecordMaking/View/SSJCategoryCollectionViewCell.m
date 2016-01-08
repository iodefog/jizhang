//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"
#import "FMDB.h"

@interface SSJCategoryCollectionViewCell()
@property (strong, nonatomic) UIButton *editButton;
@end
@implementation SSJCategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.EditeModel = NO;
        self.categorySelected = NO;
        //        self.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.categoryImage];
        [self.contentView addSubview:self.categoryName];
        [self addSubview:self.editButton];
        if (![self.item.categoryTitle isEqualToString:@"添加"]) {
            [self addLongPressGesture];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImage.centerX = self.width / 2;
    self.categoryImage.top = 3;
    self.categoryName.bottom = self.height;
    self.categoryName.centerX = self.width / 2;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        _categoryImage.layer.cornerRadius = 25;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.contentMode = UIViewContentModeCenter;
    }
    return _categoryImage;
}

-(UILabel*)categoryName{
    if (!_categoryName) {
        _categoryName = [[UILabel alloc]init];
        [_categoryName sizeToFit];
        _categoryName.font = [UIFont systemFontOfSize:15];
        _categoryName.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _categoryName.textAlignment = NSTextAlignmentCenter;        
    }
    return _categoryName;
}

-(UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
        [_editButton setImage:[UIImage imageNamed:@"edit test"] forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = 6.0f;
        _editButton.layer.masksToBounds = YES;
        _editButton.hidden = YES;
        [_editButton addTarget:self action:@selector(removeCategory:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

-(void)setItem:(SSJRecordMakingCategoryItem *)item{
    _item = item;
    [self setNeedsLayout];
    _categoryName.text = _item.categoryTitle;
    [_categoryName sizeToFit];
    _categoryImage.image = [UIImage imageNamed:self.item.categoryImage];
}

-(void)addLongPressGesture{
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPressGr];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
    self.EditeModel = YES;
}

-(void)setEditeModel:(BOOL)EditeModel{
    _EditeModel = EditeModel;
    if (_EditeModel == YES && ![self.item.categoryTitle isEqualToString:@"添加"]) {
        self.editButton.hidden = NO;
    }else{
        self.editButton.hidden = YES;
    }
}

-(void)removeCategory:(id)sender{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    [db executeUpdate:@"UPDATE BK_BILL_TYPE SET ISTATE = 0 WHERE ID = ?",self.item.categoryID];
    [db close];
    if (self.removeCategoryBlock) {
        self.removeCategoryBlock();
    }
    self.EditeModel = NO;
}

-(void)setCategorySelected:(BOOL)categorySelected{
    _categorySelected = categorySelected;
    if (categorySelected == YES) {
        self.categoryImage.layer.borderWidth = 1;
        self.categoryImage.layer.borderColor = [UIColor ssj_colorWithHex:self.item.categoryColor].CGColor;
    }else{
        self.categoryImage.layer.borderWidth = 0;
    }
}

@end
