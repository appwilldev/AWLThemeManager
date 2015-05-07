//
//  AWLThemeManager.m
//  ThemeManagerDemo
//
//  Created by Neeeo on 14-10-16.
//  Copyright (c) 2014年 AppWill. All rights reserved.
//

#import "AWLThemeManager.h"

@interface AWLThemeManager ()

@property (nonatomic, strong) NSMutableDictionary *themeList;
@property (nonatomic, strong) NSMutableDictionary *themeRelationship;
@property (nonatomic, strong) NSMutableDictionary *themeDefaultsList;

@end

@implementation AWLThemeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _themeList = [NSMutableDictionary dictionary];
        _themeRelationship = [NSMutableDictionary dictionary];
        _themeDefaultsList = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString*)addTheme:(NSString *)themePath
{
    if ([self isValidString:themePath] == NO) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:themePath] == NO) {
        return nil;
    }
    
    NSDictionary *defaults = [self defaultsForTheme:themePath];
    if (defaults) {
        NSString *themeName = defaults[@"AWL_THEME_NAME"];
        if ([self isValidString:themeName]) {
            [self.themeDefaultsList setObject:defaults forKey:themeName];
            [self.themeList setObject:themePath forKey:themeName];
            
            NSString *baseTheme = defaults[@"AWL_BASE_THEME"];
            if ([self isValidString:baseTheme]) {
                [self.themeRelationship setObject:baseTheme forKey:themeName];
            }
            
            return themeName;
        }
    }
    
    return nil;
}

- (NSDictionary*)defaultsForTheme:(NSString*)themePath
{
    NSString *path = [themePath stringByAppendingPathComponent:@"defaults.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    return nil;
}

- (NSArray *)allThemes
{
    return [self.themeList allKeys];
}

- (UIColor *)colorForKey:(NSString *)key
{
    return [self colorForKey:key forTheme:self.currentTheme];
}

- (UIColor *)colorForKey:(NSString *)key forTheme:(NSString *)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:key] == NO) {
        return nil;
    }
    
    NSString *colorValue = [self objectForKey:key forTheme:themeName];
    UIColor *color = [self colorFromString:colorValue];
    if (color == nil && [self isValidString:colorValue]) {
        color = [self colorForKey:colorValue forTheme:themeName];
    }
    
    return color;
}

- (UIColor*)colorFromString:(NSString*)colorValue
{
    if ([self isValidString:colorValue]) {
        NSArray* array = [colorValue componentsSeparatedByString:@","];
        if (array && [array count] == 4) {
            return [UIColor colorWithRed:[array[0] floatValue]/255
                                   green:[array[1] floatValue]/255
                                    blue:[array[2] floatValue]/255
                                   alpha:[array[3] floatValue]];
        }
    }
    
    return nil;
}

- (UIImage *)imageNamed:(NSString *)imgName
{
    return [self imageNamed:imgName forTheme:self.currentTheme];;
}

- (UIImage *)imageNamed:(NSString *)imgName forTheme:(NSString*)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:imgName] == NO) {
        return nil;
    }
    
    NSString *path = self.themeList[themeName];
    path = [self relativePathToMainBundle:path];
    NSString *filePath = [path stringByAppendingPathComponent:imgName];
    UIImage *img = [UIImage imageNamed:filePath];
    
    if (img == nil) {
        NSString *baseTheme = self.themeRelationship[themeName];
        if ([self isValidString:baseTheme]) {
            img = [self imageNamed:imgName forTheme:baseTheme];
        }
        else {
            img = [UIImage imageNamed:imgName];
        }
    }
    
    return img;
}

- (NSString*)relativePathToMainBundle:(NSString*)path
{
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *appDirectory = [mainBundlePath stringByDeletingLastPathComponent];
    NSString *relativePath = [path stringByReplacingOccurrencesOfString:appDirectory withString:@".."];
    return relativePath;
}

- (UIFont *)fontForKey:(NSString *)key
{
    return [self fontForKey:key forTheme:self.currentTheme];
}

- (UIFont *)fontForKey:(NSString *)key forTheme:(NSString*)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:key] == NO) {
        return nil;
    }
    
    NSString *fontValue = [self objectForKey:key forTheme:themeName];
    UIFont *font = [self fontFromString:fontValue];
    if (font == nil && [self isValidString:fontValue]) {
        font = [self fontForKey:fontValue forTheme:themeName];
    }
    
    return font;
}

- (UIFont*)fontFromString:(NSString*)fontValue
{
    UIFont *font = nil;
    if ([self isValidString:fontValue]) {
        NSArray *array = [fontValue componentsSeparatedByString:@","];
        if (array && array.count == 2) {
            NSString *fontName = array[0];
            CGFloat fontSize = [array[1] floatValue];
            if ([self isValidString:fontName]) {
                if ([fontName isEqualToString:@"bold"]) {
                    font = [UIFont boldSystemFontOfSize:fontSize];
                }
                else if ([fontName isEqualToString:@"italic"]) {
                    font = [UIFont italicSystemFontOfSize:fontSize];
                }
                else {
                    font = [UIFont fontWithName:fontName size:fontSize];
                }
            }
            else {
                font = [UIFont systemFontOfSize:fontSize];
            }
        }
    }
    
    return font;
}

- (id)objectForKey:(NSString *)key
{
    return [self objectForKey:key forTheme:self.currentTheme];
}

- (id)objectForKey:(NSString *)key forTheme:(NSString*)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:key] == NO) {
        return nil;
    }
    
    NSDictionary *defaults = self.themeDefaultsList[themeName];
    id obj = defaults[key];
    if (obj == nil) {
        NSString *baseTheme = self.themeRelationship[themeName];
        obj = [self objectForKey:key forTheme:baseTheme];
    }
    
    return obj;
}

- (NSString *)filePathForFileName:(NSString *)fileName
{
    return [self filePathForFileName:fileName forTheme:self.currentTheme];
}

- (NSString*)filePathForFileName:(NSString *)fileName forTheme:(NSString*)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:fileName] == NO) {
        return nil;
    }
    
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *themePath = self.themeList[themeName];
    NSString *filePath = [themePath stringByAppendingPathComponent:fileName];
    if ([fileManger fileExistsAtPath:filePath] == NO) {
        NSString *baseTheme = self.themeRelationship[themeName];
        filePath = [self filePathForFileName:fileName forTheme:baseTheme];
    }
    
    return filePath;
}

- (BOOL)isValidString:(NSString *)str
{
    if (str && [str isKindOfClass:[NSString class]] && [str length] > 0) {
        return YES;
    }
    
    return NO;
}

@end
