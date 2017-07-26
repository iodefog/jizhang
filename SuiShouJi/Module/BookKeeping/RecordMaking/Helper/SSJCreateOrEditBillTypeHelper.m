//
//  SSJCreateOrEditBillTypeHelper.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeHelper.h"
#import "SSJCaterotyMenuSelectionView.h"
#import "SSJBillTypeCategoryModel.h"
#import "SSJBillTypeManager.h"


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionCellItem (SSJCreateOrEditBillTypeViewController)
#pragma mark -

#define SSJCMSCellItemWithID(ID) [SSJCaterotyMenuSelectionCellItem itemWithBillID:ID]

@interface SSJCaterotyMenuSelectionCellItem (SSJCreateOrEditBillTypeViewController)

@end

@implementation SSJCaterotyMenuSelectionCellItem (SSJCreateOrEditBillTypeViewController)

+ (instancetype)itemWithBillID:(NSString *)billID {
    SSJBillTypeModel *model = SSJBillTypeModel(billID);
    return [SSJCaterotyMenuSelectionCellItem itemWithTitle:model.name icon:[UIImage imageNamed:model.icon] color:[UIColor ssj_colorWithHex:model.color]];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeHelper
#pragma mark -

@implementation SSJCreateOrEditBillTypeHelper

+ (NSArray<SSJBillTypeCategoryModel *> *)incomeCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"职业收入" items:@[SSJCMSCellItemWithID(@"2053"),
                                                                                   SSJCMSCellItemWithID(@"2001"),
                                                                                   SSJCMSCellItemWithID(@"2002"),
                                                                                   SSJCMSCellItemWithID(@"2003"),
                                                                                   SSJCMSCellItemWithID(@"2052"),
                                                                                   SSJCMSCellItemWithID(@"2011"),
                                                                                   SSJCMSCellItemWithID(@"2010"),
                                                                                   SSJCMSCellItemWithID(@"2008")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人情收入" items:@[SSJCMSCellItemWithID(@"2007"),
                                                                                   SSJCMSCellItemWithID(@"2021"),
                                                                                   SSJCMSCellItemWithID(@"2012"),
                                                                                   SSJCMSCellItemWithID(@"2051")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"生意收入" items:@[SSJCMSCellItemWithID(@"2054"),
                                                                                   SSJCMSCellItemWithID(@"2029"),
                                                                                   SSJCMSCellItemWithID(@"2052"),
                                                                                   SSJCMSCellItemWithID(@"2009"),
                                                                                   SSJCMSCellItemWithID(@"2014")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"兼职收入" items:@[SSJCMSCellItemWithID(@"2006"),
                                                                                   SSJCMSCellItemWithID(@"2055"),
                                                                                   SSJCMSCellItemWithID(@"2056"),
                                                                                   SSJCMSCellItemWithID(@"2057"),
                                                                                   SSJCMSCellItemWithID(@"2022")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"其它收入" items:@[SSJCMSCellItemWithID(@"2050"),
                                                                                   SSJCMSCellItemWithID(@"2004"),
                                                                                   SSJCMSCellItemWithID(@"2025"),
                                                                                   SSJCMSCellItemWithID(@"2020"),
                                                                                   SSJCMSCellItemWithID(@"2009"),
                                                                                   SSJCMSCellItemWithID(@"2033"),
                                                                                   SSJCMSCellItemWithID(@"2058"),
                                                                                   SSJCMSCellItemWithID(@"2026"),
                                                                                   SSJCMSCellItemWithID(@"2039"),
                                                                                   SSJCMSCellItemWithID(@"2028")]]];
    return [categories copy];
}

+ (NSArray<SSJBillTypeCategoryModel *> *)expenseCategoriesWithBooksType:(SSJBooksType)booksType {
    switch (booksType) {
        case SSJBooksTypeDaily:
            return [[self organiseDailyCategories] copy];
            break;
            
        case SSJBooksTypeBusiness:
            return [[self organiseBusinessCategories] copy];
            break;
            
        case SSJBooksTypeMarriage:
            return [[self organiseMarriageCategories] copy];
            break;
            
        case SSJBooksTypeDecoration:
            return [[self organiseDecorationCategories] copy];
            break;
            
        case SSJBooksTypeTravel:
            return [[self organiseTravelCategories] copy];
            break;
            
        case SSJBooksTypeBaby:
            return [[self organiseBabyCategories] copy];
            break;
    }
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseDailyCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"餐饮" items:@[SSJCMSCellItemWithID(@"1000"),
                                                                                  SSJCMSCellItemWithID(@"1189"),
                                                                                  SSJCMSCellItemWithID(@"1173"),
                                                                                  SSJCMSCellItemWithID(@"1172"),
                                                                                  SSJCMSCellItemWithID(@"1013"),
                                                                                  SSJCMSCellItemWithID(@"1012")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"购物" items:@[SSJCMSCellItemWithID(@"1003"),
                                                                                  SSJCMSCellItemWithID(@"1035"),
                                                                                  SSJCMSCellItemWithID(@"1016"),
                                                                                  SSJCMSCellItemWithID(@"1037"),
                                                                                  SSJCMSCellItemWithID(@"1028"),
                                                                                  SSJCMSCellItemWithID(@"1015"),
                                                                                  SSJCMSCellItemWithID(@"1046"),
                                                                                  SSJCMSCellItemWithID(@"1177")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"交通" items:@[SSJCMSCellItemWithID(@"1002"),
                                                                                  SSJCMSCellItemWithID(@"1196"),
                                                                                  SSJCMSCellItemWithID(@"1144"),
                                                                                  SSJCMSCellItemWithID(@"1139"),
                                                                                  SSJCMSCellItemWithID(@"1138"),
                                                                                  SSJCMSCellItemWithID(@"1121"),
                                                                                  SSJCMSCellItemWithID(@"1044"),
                                                                                  SSJCMSCellItemWithID(@"1166")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"居住" items:@[SSJCMSCellItemWithID(@"1009"),
                                                                                  SSJCMSCellItemWithID(@"1020"),
                                                                                  SSJCMSCellItemWithID(@"1007"),
                                                                                  SSJCMSCellItemWithID(@"1010"),
                                                                                  SSJCMSCellItemWithID(@"1025"),
                                                                                  SSJCMSCellItemWithID(@"1027"),
                                                                                  SSJCMSCellItemWithID(@"1057")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"娱乐" items:@[SSJCMSCellItemWithID(@"1004"),
                                                                                  SSJCMSCellItemWithID(@"1040"),
                                                                                  SSJCMSCellItemWithID(@"1017"),
                                                                                  SSJCMSCellItemWithID(@"1023"),
                                                                                  SSJCMSCellItemWithID(@"1186"),
                                                                                  SSJCMSCellItemWithID(@"1048"),
                                                                                  SSJCMSCellItemWithID(@"1049"),
                                                                                  SSJCMSCellItemWithID(@"1127")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"医疗" items:@[SSJCMSCellItemWithID(@"1008"),
                                                                                  SSJCMSCellItemWithID(@"1180"),
                                                                                  SSJCMSCellItemWithID(@"1192"),
                                                                                  SSJCMSCellItemWithID(@"1074")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"教育" items:@[SSJCMSCellItemWithID(@"1022"),
                                                                                  SSJCMSCellItemWithID(@"1179"),
                                                                                  SSJCMSCellItemWithID(@"1165"),
                                                                                  SSJCMSCellItemWithID(@"1155")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人情" items:@[SSJCMSCellItemWithID(@"1160"),
                                                                                  SSJCMSCellItemWithID(@"1158"),
                                                                                  SSJCMSCellItemWithID(@"1151"),
                                                                                  SSJCMSCellItemWithID(@"1034"),
                                                                                  SSJCMSCellItemWithID(@"1176"),
                                                                                  SSJCMSCellItemWithID(@"1019")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"其它" items:@[SSJCMSCellItemWithID(@"1033"),
                                                                                  SSJCMSCellItemWithID(@"1005"),
                                                                                  SSJCMSCellItemWithID(@"1184"),
                                                                                  SSJCMSCellItemWithID(@"1031"),
                                                                                  SSJCMSCellItemWithID(@"1056"),
                                                                                  SSJCMSCellItemWithID(@"1051"),
                                                                                  SSJCMSCellItemWithID(@"1026")]]];
    return categories;
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseBabyCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝食物" items:@[SSJCMSCellItemWithID(@"1130"),
                                                                                    SSJCMSCellItemWithID(@"1038"),
                                                                                    SSJCMSCellItemWithID(@"1143")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝用品" items:@[SSJCMSCellItemWithID(@"1131"),
                                                                                    SSJCMSCellItemWithID(@"1181"),
                                                                                    SSJCMSCellItemWithID(@"1039"),
                                                                                    SSJCMSCellItemWithID(@"1164"),
                                                                                    SSJCMSCellItemWithID(@"1174"),
                                                                                    SSJCMSCellItemWithID(@"1137"),
                                                                                    SSJCMSCellItemWithID(@"1190"),
                                                                                    SSJCMSCellItemWithID(@"1170"),
                                                                                    SSJCMSCellItemWithID(@"1168"),
                                                                                    SSJCMSCellItemWithID(@"1171")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"医疗护理" items:@[SSJCMSCellItemWithID(@"1182"),
                                                                                    SSJCMSCellItemWithID(@"1183"),
                                                                                    SSJCMSCellItemWithID(@"1132"),
                                                                                    SSJCMSCellItemWithID(@"1134"),
                                                                                    SSJCMSCellItemWithID(@"1128"),
                                                                                    SSJCMSCellItemWithID(@"1187")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝其它" items:@[SSJCMSCellItemWithID(@"1129"),
                                                                                    SSJCMSCellItemWithID(@"1047"),
                                                                                    SSJCMSCellItemWithID(@"1178"),
                                                                                    SSJCMSCellItemWithID(@"1162")]]];
    return categories;
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseBusinessCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"货品材料" items:@[SSJCMSCellItemWithID(@"1146"),
                                                                                    SSJCMSCellItemWithID(@"1058"),
                                                                                    SSJCMSCellItemWithID(@"1059"),
                                                                                    SSJCMSCellItemWithID(@"1060")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人工支出" items:@[SSJCMSCellItemWithID(@"1159"),
                                                                                    SSJCMSCellItemWithID(@"1064"),
                                                                                    SSJCMSCellItemWithID(@"1191"),
                                                                                    SSJCMSCellItemWithID(@"1169")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"运营费用" items:@[SSJCMSCellItemWithID(@"1188"),
                                                                                    SSJCMSCellItemWithID(@"1061"),
                                                                                    SSJCMSCellItemWithID(@"1150"),
                                                                                    SSJCMSCellItemWithID(@"1071")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"办公费用" items:@[SSJCMSCellItemWithID(@"1062"),
                                                                                    SSJCMSCellItemWithID(@"1142"),
                                                                                    SSJCMSCellItemWithID(@"1067"),
                                                                                    SSJCMSCellItemWithID(@"1041")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"固定资产" items:@[SSJCMSCellItemWithID(@"1041"),
                                                                                    SSJCMSCellItemWithID(@"1068"),
                                                                                    SSJCMSCellItemWithID(@"1141"),
                                                                                    SSJCMSCellItemWithID(@"1135")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"生意其它" items:@[SSJCMSCellItemWithID(@"1163"),
                                                                                    SSJCMSCellItemWithID(@"1065"),
                                                                                    SSJCMSCellItemWithID(@"1066"),
                                                                                    SSJCMSCellItemWithID(@"1052"),
                                                                                    SSJCMSCellItemWithID(@"1194"),
                                                                                    SSJCMSCellItemWithID(@"1025"),
                                                                                    SSJCMSCellItemWithID(@"1074"),
                                                                                    SSJCMSCellItemWithID(@"1072")]]];
    return categories;
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseTravelCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"餐饮" items:@[SSJCMSCellItemWithID(@"1000"),
                                                                                  SSJCMSCellItemWithID(@"1117"),
                                                                                  SSJCMSCellItemWithID(@"1013"),
                                                                                  SSJCMSCellItemWithID(@"1001")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"交通" items:@[SSJCMSCellItemWithID(@"1002"),
                                                                                  SSJCMSCellItemWithID(@"1044"),
                                                                                  SSJCMSCellItemWithID(@"1122"),
                                                                                  SSJCMSCellItemWithID(@"1136"),
                                                                                  SSJCMSCellItemWithID(@"1193"),
                                                                                  SSJCMSCellItemWithID(@"1043"),
                                                                                  SSJCMSCellItemWithID(@"1157"),
                                                                                  SSJCMSCellItemWithID(@"1154")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"娱乐费用" items:@[SSJCMSCellItemWithID(@"1004"),
                                                                                    SSJCMSCellItemWithID(@"1149"),
                                                                                    SSJCMSCellItemWithID(@"1114"),
                                                                                    SSJCMSCellItemWithID(@"1126")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"旅游购物" items:@[SSJCMSCellItemWithID(@"1153"),
                                                                                    SSJCMSCellItemWithID(@"1167"),
                                                                                    SSJCMSCellItemWithID(@"1119"),
                                                                                    SSJCMSCellItemWithID(@"1123")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"旅行其它" items:@[SSJCMSCellItemWithID(@"1152"),
                                                                                    SSJCMSCellItemWithID(@"1125"),
                                                                                    SSJCMSCellItemWithID(@"1156"),
                                                                                    SSJCMSCellItemWithID(@"1175")]]];
    return categories;
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseDecorationCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"软装" items:@[SSJCMSCellItemWithID(@"1161"),
                                                                                  SSJCMSCellItemWithID(@"1099"),
                                                                                  SSJCMSCellItemWithID(@"1109"),
                                                                                  SSJCMSCellItemWithID(@"1100"),
                                                                                  SSJCMSCellItemWithID(@"1098"),
                                                                                  SSJCMSCellItemWithID(@"1097"),
                                                                                  SSJCMSCellItemWithID(@"1102")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"硬装" items:@[SSJCMSCellItemWithID(@"1185"),
                                                                                  SSJCMSCellItemWithID(@"1095"),
                                                                                  SSJCMSCellItemWithID(@"1101"),
                                                                                  SSJCMSCellItemWithID(@"1096")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"装修人工" items:@[SSJCMSCellItemWithID(@"1105"),
                                                                                    SSJCMSCellItemWithID(@"1000"),
                                                                                    SSJCMSCellItemWithID(@"1002"),
                                                                                    SSJCMSCellItemWithID(@"1009")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"装修其它" items:@[SSJCMSCellItemWithID(@"1195"),
                                                                                    SSJCMSCellItemWithID(@"1103"),
                                                                                    SSJCMSCellItemWithID(@"1106"),
                                                                                    SSJCMSCellItemWithID(@"1110")]]];
    return categories;
}

+ (NSArray<SSJBillTypeCategoryModel *> *)organiseMarriageCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"结婚物品" items:@[SSJCMSCellItemWithID(@"1148"),
                                                                                    SSJCMSCellItemWithID(@"1077"),
                                                                                    SSJCMSCellItemWithID(@"1082"),
                                                                                    SSJCMSCellItemWithID(@"1092")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"婚礼支出" items:@[SSJCMSCellItemWithID(@"1145"),
                                                                                    SSJCMSCellItemWithID(@"1083"),
                                                                                    SSJCMSCellItemWithID(@"1001"),
                                                                                    SSJCMSCellItemWithID(@"1085"),
                                                                                    SSJCMSCellItemWithID(@"1081"),
                                                                                    SSJCMSCellItemWithID(@"1087"),
                                                                                    SSJCMSCellItemWithID(@"1086")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"度蜜月" items:@[SSJCMSCellItemWithID(@"1140"),
                                                                                   SSJCMSCellItemWithID(@"1000"),
                                                                                   SSJCMSCellItemWithID(@"1002"),
                                                                                   SSJCMSCellItemWithID(@"1009")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"结婚其它" items:@[SSJCMSCellItemWithID(@"1147"),
                                                                                    SSJCMSCellItemWithID(@"1080"),
                                                                                    SSJCMSCellItemWithID(@"1034")]]];
    return categories;
}

@end
