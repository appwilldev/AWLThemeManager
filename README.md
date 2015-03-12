# AWLThemeManager

AWLThemeManager which uses bundle as the module is a lightweight theme manager for iOS.

## Features

### What can be customized

1. Image;
2. Font;
3. Color;
4. Property-list supported objects
5. Any file in bundle.

### Theme Inheritance

In actual work, there may be a little difference among themes. In a traditional way, you need to keep the same content in every theme. This is a bad way if you want to change the value, you need find all the places and change it.
From now on, you can feel release if you want to do that because of the inheritance of AWLThemeManager. You just need to modify the root theme then all the themes that inheritant from the root theme will be changed to the new value.

## How to use

### Import to your poject

* Use cocoapods

        pod 'AWLThemeManager'
    
* Traditional way
	Just add the header and source file to your project
	* AWLThemeManager.h
	* AWLThemeManager.m

### Write your own bundle file

The structure of bundle file is below:

![Bundle](http://ww1.sinaimg.cn/large/73941b03jw1eq2u5jqhm2j204w01k3yg.jpg)

defaults.plist is necessary. Add other files to the root directory of bundle.

### defaults.plist
defaults.plist is used to set the property of themes, include color, font etc.

![defaults.plist](http://ww4.sinaimg.cn/large/73941b03jw1eq2u3kp0vpj20d0037t8x.jpg)

#### bease info
Default key used in defualts.plist:

* AWL_THEME_NAME

 	This key is necessary. it is the name of the theme, used to identify the theme, must be only. 

* AWL_BASE_THEME

	Alternative. If you want to use theme as your base theme, you should add this key. Set the name of base theme to this key.
	
#### Define Color
The format of color is :

![defaults.plist](http://ww1.sinaimg.cn/large/73941b03jw1eq2u3jquu6j20bc00mjr9.jpg)

It will return the color use follow method:
	
    [UIColor colorWithRed:[array[0] floatValue]/255
                    green:[array[1] floatValue]/255
                     blue:[array[2] floatValue]/255
                    alpha:[array[3] floatValue]];
    
Make sure you set the right value to the color.

**Support reference** If you want to the same value to different color key, you can set the key of one color to another color, then AWLThemeManager will find the actual value of the color.

#### Define Font
The format of font is :

![defaults.plist](http://ww2.sinaimg.cn/large/73941b03jw1eq2u3l0thcj20c500rwed.jpg)

The first one is name of font, second is size of the font.
It will return the font use follow method:

	[UIFont fontWithName:fontName size:fontSize]
	
If you want to use system font, you should ignore the first value, like this:

	,14       //systemFontOfSize
    bold,14   //boldSystemFontOfSize
    italic,14 //italicSystemFontOfSize
    
**Support reference** Same with the color

You can add whatever you want to the defaults.plist. Just use  `objectForKey:` to get the value.

### How to use in your project

Add the absolute path of bundle to AWLThemeManager object, then set the current theme that you want.
For example:

```objc
NSString *bundlePath1 = [[NSBundle mainBundle] pathForResource:@"BaseSample" ofType:@"bundle"];
NSString *bundlePath2 = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"bundle"];
AWLThemeManager *mgr = [[AWLThemeManager alloc] init];
[mgr addTheme:bundlePath1];
mgr.currentTheme = [mgr addTheme:bundlePath2];
``` 

Then you can access the resource use the same AWLThemeManager object as follow.
	
```objc
UIImage *img = [mgr imageNamed:@"icon"];
titleLabel.textColor = [mgr colorForKey:@"Content_Text_Color"];
titleLabel.font = [mgr fontForKey:@"Content_Font"];
```






