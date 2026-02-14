//
//  TLProgressSlider.h
//  Hachi
//
//  Created by Waylens Administrator on 7/29/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TLProgressSliderDelegate <NSObject>
-(void)slideBegan;
-(void)slideEnded;

@end

@interface TLProgressSlider : UISlider
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, weak) id<TLProgressSliderDelegate> delegate;
@property (nonatomic, assign) BOOL isDragging;
-(UIImage *)thumbForSize:(CGSize)size;
@end
