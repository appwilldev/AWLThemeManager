//
//  AWLThemeManager.h
//  ThemeManagerDemo
//
//  Created by Neeeo on 14-10-16.
//  Copyright (c) 2014年 AppWill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AWLThemeManager : NSObject

@property (nonatomic, strong) NSString *currentTheme;

// return themeName
- (NSString*)addTheme:(NSString*)themePath;
- (NSArray*)allThemes;

//Get color from defaults.plist
- (UIColor*)colorForKey:(NSString*)key;
- (UIColor*)colorForKey:(NSString*)key forTheme:(NSString*)themeName;

//Get font from defaults.plist
- (UIFont*)fontForKey:(NSString*)key;
- (UIFont *)fontForKey:(NSString *)key forTheme:(NSString*)themeName;

//Get img name from defaults.plist, and then img from theme bundle. Use key as image name if img name is missed.
- (UIImage*)imageNamed:(NSString*)key;
- (UIImage *)imageNamed:(NSString *)key forTheme:(NSString*)themeName;

//key in defaults.plist of the current theme
- (id)objectForKey:(NSString*)key;
- (id)objectForKey:(NSString *)key forTheme:(NSString*)themeName;

//file path in the current theme bundle
- (NSString*)filePathForFileName:(NSString*)fileName;
- (NSString*)filePathForFileName:(NSString *)fileName forTheme:(NSString*)themeName;

@end
