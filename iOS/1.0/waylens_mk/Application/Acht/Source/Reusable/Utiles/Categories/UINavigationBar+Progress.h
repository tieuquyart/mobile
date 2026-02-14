//
//  UINavigationBar+Progress.h
//  Hachi
//
//  Created by lzhu on 3/16/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Progress)

//must set enableProgress to YES， before call other methods, otherwise nonthing happens
@property (assign, nonatomic) BOOL enableProgress;

@property (assign, nonatomic) BOOL progressHidden;

@property (assign, nonatomic) CGFloat progress; //at range of [0, 1]

@property (strong, nonatomic) UIColor *progressBackgroundColor;
@property (strong, nonatomic) UIColor *progressTintColor;

@end


@interface UINavigationBar (ProgressIndicator)

//must set enableIndicator to YES， before call other methods, otherwise nonthing happens
@property (assign, nonatomic) BOOL enableIndicator;

@property (assign, nonatomic) BOOL indicatorHidden;

@property (strong, nonatomic) NSString *indicatorText;

@property (strong, nonatomic) UIColor *indicatorTextColor;

@property (assign, nonatomic) CGFloat indicatorPosition; //at range of [0, 1], same to property of progress

@property (strong, nonatomic) UIImage *indicatorImage;


@end
