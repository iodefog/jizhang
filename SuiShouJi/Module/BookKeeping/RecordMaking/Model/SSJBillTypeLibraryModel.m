//
//  SSJBillTypeLibraryModel.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBillTypeLibraryModel.h"
#import "SSJBillTypeCategoryModel.h"
#import "SSJBillTypeManager.h"

@interface SSJBillTypeLibraryModel ()

@property (nonatomic) SSJBooksType booksType;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *incomeCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *dailyCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *babyCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *businessCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *travelCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *decorationCategories;

@property (nonatomic, strong) NSArray<SSJBillTypeCategoryModel *> *marriageCategories;

@end

@implementation SSJBillTypeLibraryModel

- (NSArray<SSJBillTypeCategoryModel *> *)expenseCategoriesWithBooksType:(SSJBooksType)booksType {
    switch (booksType) {
        case SSJBooksTypeDaily:
            return self.dailyCategories;
            break;
            
        case SSJBooksTypeBusiness:
            return self.businessCategories;
            break;
            
        case SSJBooksTypeMarriage:
            return self.marriageCategories;
            break;
            
        case SSJBooksTypeDecoration:
            return self.decorationCategories;
            break;
            
        case SSJBooksTypeTravel:
            return self.travelCategories;
            break;
            
        case SSJBooksTypeBaby:
            return self.babyCategories;
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSArray<SSJBillTypeCategoryModel *> *)incomeCategories {
    if (!_incomeCategories) {
        _incomeCategories = [self organiseIncomeCategories];
    }
    return _incomeCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)dailyCategories {
    if (!_dailyCategories) {
        _dailyCategories = [self organiseDailyCategories];
    }
    return _dailyCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)babyCategories {
    if (!_babyCategories) {
        _babyCategories = [self organiseBabyCategories];
    }
    return _babyCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)businessCategories {
    if (!_businessCategories) {
        _businessCategories = [self organiseBusinessCategories];
    }
    return _businessCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)travelCategories {
    if (!_travelCategories) {
        _travelCategories = [self organiseTravelCategories];
    }
    return _travelCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)decorationCategories {
    if (!_decorationCategories) {
        _decorationCategories = [self organiseDecorationCategories];
    }
    return _decorationCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)marriageCategories {
    if (!_marriageCategories) {
        _marriageCategories = [self organiseMarriageCategories];
    }
    return _marriageCategories;
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseIncomeCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"职业收入" items:@[SSJBillTypeModel(@"2053"),
                                                                                   SSJBillTypeModel(@"2001"),
                                                                                   SSJBillTypeModel(@"2002"),
                                                                                   SSJBillTypeModel(@"2003"),
                                                                                   SSJBillTypeModel(@"2052"),
                                                                                   SSJBillTypeModel(@"2011"),
                                                                                   SSJBillTypeModel(@"2010"),
                                                                                   SSJBillTypeModel(@"2008")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人情收入" items:@[SSJBillTypeModel(@"2007"),
                                                                                   SSJBillTypeModel(@"2021"),
                                                                                   SSJBillTypeModel(@"2005"),
                                                                                   SSJBillTypeModel(@"2012"),
                                                                                   SSJBillTypeModel(@"2051")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"生意收入" items:@[SSJBillTypeModel(@"2054"),
                                                                                   SSJBillTypeModel(@"2029"),
                                                                                   SSJBillTypeModel(@"2052"),
                                                                                   SSJBillTypeModel(@"2009"),
                                                                                   SSJBillTypeModel(@"2014")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"兼职收入" items:@[SSJBillTypeModel(@"2006"),
                                                                                   SSJBillTypeModel(@"2055"),
                                                                                   SSJBillTypeModel(@"2056"),
                                                                                   SSJBillTypeModel(@"2057"),
                                                                                   SSJBillTypeModel(@"2022")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"其它收入" items:@[SSJBillTypeModel(@"2050"),
                                                                                   SSJBillTypeModel(@"2004"),
                                                                                   SSJBillTypeModel(@"2025"),
                                                                                   SSJBillTypeModel(@"2020"),
                                                                                   SSJBillTypeModel(@"2009"),
                                                                                   SSJBillTypeModel(@"2033"),
                                                                                   SSJBillTypeModel(@"2058"),
                                                                                   SSJBillTypeModel(@"2026"),
                                                                                   SSJBillTypeModel(@"2039"),
                                                                                   SSJBillTypeModel(@"2028")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseDailyCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"餐饮" items:@[SSJBillTypeModel(@"1000"),
                                                                                 SSJBillTypeModel(@"1189"),
                                                                                 SSJBillTypeModel(@"1173"),
                                                                                 SSJBillTypeModel(@"1172"),
                                                                                 SSJBillTypeModel(@"1013"),
                                                                                 SSJBillTypeModel(@"1012"),
                                                                                 SSJBillTypeModel(@"1036"),
                                                                                 SSJBillTypeModel(@"1001")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"购物" items:@[SSJBillTypeModel(@"1003"),
                                                                                 SSJBillTypeModel(@"1035"),
                                                                                 SSJBillTypeModel(@"1016"),
                                                                                 SSJBillTypeModel(@"1037"),
                                                                                 SSJBillTypeModel(@"1028"),
                                                                                 SSJBillTypeModel(@"1015"),
                                                                                 SSJBillTypeModel(@"1046"),
                                                                                 SSJBillTypeModel(@"1177")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"交通" items:@[SSJBillTypeModel(@"1002"),
                                                                                 SSJBillTypeModel(@"1196"),
                                                                                 SSJBillTypeModel(@"1144"),
                                                                                 SSJBillTypeModel(@"1139"),
                                                                                 SSJBillTypeModel(@"1138"),
                                                                                 SSJBillTypeModel(@"1121"),
                                                                                 SSJBillTypeModel(@"1044"),
                                                                                 SSJBillTypeModel(@"1166")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"居住" items:@[SSJBillTypeModel(@"1009"),
                                                                                 SSJBillTypeModel(@"1020"),
                                                                                 SSJBillTypeModel(@"1007"),
                                                                                 SSJBillTypeModel(@"1010"),
                                                                                 SSJBillTypeModel(@"1025"),
                                                                                 SSJBillTypeModel(@"1027"),
                                                                                 SSJBillTypeModel(@"1057")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"娱乐" items:@[SSJBillTypeModel(@"1004"),
                                                                                 SSJBillTypeModel(@"1040"),
                                                                                 SSJBillTypeModel(@"1017"),
                                                                                 SSJBillTypeModel(@"1023"),
                                                                                 SSJBillTypeModel(@"1186"),
                                                                                 SSJBillTypeModel(@"1048"),
                                                                                 SSJBillTypeModel(@"1049"),
                                                                                 SSJBillTypeModel(@"1127")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"医疗" items:@[SSJBillTypeModel(@"1008"),
                                                                                 SSJBillTypeModel(@"1180"),
                                                                                 SSJBillTypeModel(@"1192"),
                                                                                 SSJBillTypeModel(@"1074")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"教育" items:@[SSJBillTypeModel(@"1022"),
                                                                                 SSJBillTypeModel(@"1179"),
                                                                                 SSJBillTypeModel(@"1165"),
                                                                                 SSJBillTypeModel(@"1155")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人情" items:@[SSJBillTypeModel(@"1160"),
                                                                                 SSJBillTypeModel(@"1158"),
                                                                                 SSJBillTypeModel(@"1151"),
                                                                                 SSJBillTypeModel(@"1034"),
                                                                                 SSJBillTypeModel(@"1176"),
                                                                                 SSJBillTypeModel(@"1019")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"其它" items:@[SSJBillTypeModel(@"1033"),
                                                                                 SSJBillTypeModel(@"1005"),
                                                                                 SSJBillTypeModel(@"1184"),
                                                                                 SSJBillTypeModel(@"1031"),
                                                                                 SSJBillTypeModel(@"1056"),
                                                                                 SSJBillTypeModel(@"1051"),
                                                                                 SSJBillTypeModel(@"1026")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseBabyCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝食物" items:@[SSJBillTypeModel(@"1130"),
                                                                                   SSJBillTypeModel(@"1038"),
                                                                                   SSJBillTypeModel(@"1143")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝用品" items:@[SSJBillTypeModel(@"1131"),
                                                                                   SSJBillTypeModel(@"1181"),
                                                                                   SSJBillTypeModel(@"1039"),
                                                                                   SSJBillTypeModel(@"1164"),
                                                                                   SSJBillTypeModel(@"1174"),
                                                                                   SSJBillTypeModel(@"1137"),
                                                                                   SSJBillTypeModel(@"1190"),
                                                                                   SSJBillTypeModel(@"1170"),
                                                                                   SSJBillTypeModel(@"1168"),
                                                                                   SSJBillTypeModel(@"1171")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"医疗护理" items:@[SSJBillTypeModel(@"1182"),
                                                                                   SSJBillTypeModel(@"1183"),
                                                                                   SSJBillTypeModel(@"1132"),
                                                                                   SSJBillTypeModel(@"1134"),
                                                                                   SSJBillTypeModel(@"1128"),
                                                                                   SSJBillTypeModel(@"1187")]]];
    
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"宝宝其它" items:@[SSJBillTypeModel(@"1129"),
                                                                                   SSJBillTypeModel(@"1047"),
                                                                                   SSJBillTypeModel(@"1178"),
                                                                                   SSJBillTypeModel(@"1162")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseBusinessCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"货品材料" items:@[SSJBillTypeModel(@"1146"),
                                                                                   SSJBillTypeModel(@"1058"),
                                                                                   SSJBillTypeModel(@"1059"),
                                                                                   SSJBillTypeModel(@"1060")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"人工支出" items:@[SSJBillTypeModel(@"1159"),
                                                                                   SSJBillTypeModel(@"1064"),
                                                                                   SSJBillTypeModel(@"1191"),
                                                                                   SSJBillTypeModel(@"1169")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"运营费用" items:@[SSJBillTypeModel(@"1188"),
                                                                                   SSJBillTypeModel(@"1061"),
                                                                                   SSJBillTypeModel(@"1150"),
                                                                                   SSJBillTypeModel(@"1071")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"办公费用" items:@[SSJBillTypeModel(@"1062"),
                                                                                   SSJBillTypeModel(@"1142"),
                                                                                   SSJBillTypeModel(@"1067"),
                                                                                   SSJBillTypeModel(@"1041")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"固定资产" items:@[SSJBillTypeModel(@"1197"),
                                                                                   SSJBillTypeModel(@"1068"),
                                                                                   SSJBillTypeModel(@"1141"),
                                                                                   SSJBillTypeModel(@"1135")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"生意其它" items:@[SSJBillTypeModel(@"1163"),
                                                                                   SSJBillTypeModel(@"1065"),
                                                                                   SSJBillTypeModel(@"1066"),
                                                                                   SSJBillTypeModel(@"1052"),
                                                                                   SSJBillTypeModel(@"1194"),
                                                                                   SSJBillTypeModel(@"1025"),
                                                                                   SSJBillTypeModel(@"1074"),
                                                                                   SSJBillTypeModel(@"1072")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseTravelCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"餐饮" items:@[SSJBillTypeModel(@"1000"),
                                                                                 SSJBillTypeModel(@"1117"),
                                                                                 SSJBillTypeModel(@"1013"),
                                                                                 SSJBillTypeModel(@"1001")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"交通" items:@[SSJBillTypeModel(@"1002"),
                                                                                 SSJBillTypeModel(@"1044"),
                                                                                 SSJBillTypeModel(@"1122"),
                                                                                 SSJBillTypeModel(@"1136"),
                                                                                 SSJBillTypeModel(@"1193"),
                                                                                 SSJBillTypeModel(@"1043"),
                                                                                 SSJBillTypeModel(@"1157"),
                                                                                 SSJBillTypeModel(@"1154")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"娱乐费用" items:@[SSJBillTypeModel(@"1004"),
                                                                                   SSJBillTypeModel(@"1149"),
                                                                                   SSJBillTypeModel(@"1114"),
                                                                                   SSJBillTypeModel(@"1126")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"旅游购物" items:@[SSJBillTypeModel(@"1153"),
                                                                                   SSJBillTypeModel(@"1167"),
                                                                                   SSJBillTypeModel(@"1119"),
                                                                                   SSJBillTypeModel(@"1123")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"旅行其它" items:@[SSJBillTypeModel(@"1152"),
                                                                                   SSJBillTypeModel(@"1125"),
                                                                                   SSJBillTypeModel(@"1156"),
                                                                                   SSJBillTypeModel(@"1175")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseDecorationCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"软装" items:@[SSJBillTypeModel(@"1161"),
                                                                                 SSJBillTypeModel(@"1099"),
                                                                                 SSJBillTypeModel(@"1109"),
                                                                                 SSJBillTypeModel(@"1100"),
                                                                                 SSJBillTypeModel(@"1098"),
                                                                                 SSJBillTypeModel(@"1097"),
                                                                                 SSJBillTypeModel(@"1102")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"硬装" items:@[SSJBillTypeModel(@"1185"),
                                                                                 SSJBillTypeModel(@"1095"),
                                                                                 SSJBillTypeModel(@"1101"),
                                                                                 SSJBillTypeModel(@"1096")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"装修人工" items:@[SSJBillTypeModel(@"1105"),
                                                                                   SSJBillTypeModel(@"1000"),
                                                                                   SSJBillTypeModel(@"1002"),
                                                                                   SSJBillTypeModel(@"1193")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"装修其它" items:@[SSJBillTypeModel(@"1195"),
                                                                                   SSJBillTypeModel(@"1103"),
                                                                                   SSJBillTypeModel(@"1106"),
                                                                                   SSJBillTypeModel(@"1110")]]];
    return [categories copy];
}

- (NSArray<SSJBillTypeCategoryModel *> *)organiseMarriageCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"结婚物品" items:@[SSJBillTypeModel(@"1148"),
                                                                                   SSJBillTypeModel(@"1077"),
                                                                                   SSJBillTypeModel(@"1082"),
                                                                                   SSJBillTypeModel(@"1092")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"婚礼支出" items:@[SSJBillTypeModel(@"1145"),
                                                                                   SSJBillTypeModel(@"1083"),
                                                                                   SSJBillTypeModel(@"1001"),
                                                                                   SSJBillTypeModel(@"1085"),
                                                                                   SSJBillTypeModel(@"1081"),
                                                                                   SSJBillTypeModel(@"1087"),
                                                                                   SSJBillTypeModel(@"1086")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"度蜜月" items:@[SSJBillTypeModel(@"1140"),
                                                                                  SSJBillTypeModel(@"1000"),
                                                                                  SSJBillTypeModel(@"1002"),
                                                                                  SSJBillTypeModel(@"1193")]]];
    [categories addObject:[SSJBillTypeCategoryModel modelWithTitle:@"结婚其它" items:@[SSJBillTypeModel(@"1147"),
                                                                                   SSJBillTypeModel(@"1080"),
                                                                                   SSJBillTypeModel(@"1034")]]];
    return [categories copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"incomeCategories:%@ \nexpenseCategories:%@", [self incomeCategories], [self expenseCategoriesWithBooksType:self.booksType]];
}

@end
