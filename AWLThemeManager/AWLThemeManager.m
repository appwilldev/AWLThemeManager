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
        NSArray* referenceColor = [colorValue componentsSeparatedByString:@":"];
        colorValue = referenceColor.firstObject;
        color = [self colorForKey:colorValue forTheme:themeName];
        if (referenceColor.count > 1) {
            color = [color colorWithAlphaComponent:[referenceColor[1] doubleValue]];
        }
    }
    
    return color;
}

- (UIColor*)colorFromString:(NSString*)colorValue
{
    if ([self isValidString:colorValue]) {
        
        if ([colorValue hasPrefix: @"#"]) {
            NSArray*  array       = [colorValue componentsSeparatedByString:@","];
            NSString* patternName = [array[0] substringFromIndex:1];
            UIImage* patternImage = [self imageNamed:patternName];
            if (patternImage == nil) {
                return nil;
            }
            UIColor* color = [UIColor colorWithPatternImage: patternImage];
            if (array.count == 2) {
                color = [color colorWithAlphaComponent: [array[1] doubleValue]];
            }
            return color;
        }
        NSArray* array = [colorValue componentsSeparatedByString:@","];
        if (array && [array count] == 2) {
            return [UIColor colorWithWhite:[array[0] doubleValue]
                                     alpha:[array[1] doubleValue]];
        }
        else if (array && [array count] == 4) {
            return [UIColor colorWithRed:[array[0] doubleValue]/255.0
                                   green:[array[1] doubleValue]/255.0
                                    blue:[array[2] doubleValue]/255.0
                                   alpha:[array[3] doubleValue]];
        }
    }
    
    return nil;
}

- (UIImage *)imageNamed:(NSString *)key
{
    return [self imageNamed:key forTheme:self.currentTheme];;
}

- (UIImage *)imageNamed:(NSString *)key forTheme:(NSString*)themeName
{
    if ([self isValidString:themeName] == NO || [self isValidString:key] == NO) {
        return nil;
    }
    
    NSString *imgName = [self objectForKey:key forTheme:themeName];
    
    if (imgName == nil) {
        imgName = key;
    }
    
    UIImage*  img    = nil;
    NSBundle* bundle = [NSBundle bundleWithPath:self.themeList[themeName]];
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        img = [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:nil];
    }
#ifdef AWLThemeManager_XCASSETS_iOS7
    else {
        //This is included for reference/completeness. It fetches the device specific
        //image from the compiled Assets.car embedded in the theme bundle for iOS7 devices.
        //However, it is a *PRIVATE API*
        //As such, all relevant warnings and caveats apply to it's usage
        //IF you want to enable with cocoapods you'll need this:
        //https://guides.cocoapods.org/syntax/podfile.html#post_install
        static NSString* iOS7PrivateCompatSelector = @"_" @"device" @"Specific" @"ImageNamed:" @"inBundle:";
        SEL deviceImageNamed = NSSelectorFromString(iOS7PrivateCompatSelector);
        if ([UIImage respondsToSelector: deviceImageNamed]) {
        img = [UIImage performSelector: deviceImageNamed withObject:imgName withObject:bundle];
        }
    }
#endif
    
    if (img == nil) {
        NSString *path = self.themeList[themeName];
        path = [self relativePathToMainBundle:path];
        NSString *filePath = [path stringByAppendingPathComponent:imgName];
        img = [UIImage imageNamed:filePath];
    }
    
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
            CGFloat fontSize = [array[1] doubleValue];
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
