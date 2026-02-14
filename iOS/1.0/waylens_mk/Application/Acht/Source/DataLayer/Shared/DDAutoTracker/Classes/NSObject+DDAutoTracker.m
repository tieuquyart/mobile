//
//  NSObject+DDAutoTracker.m
//  DDAutoTracker
//
//  Created by 王海亮 on 2017/12/18.
//

#import "NSObject+DDAutoTracker.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
static void * ddInfoDictionaryPropertyKey = &ddInfoDictionaryPropertyKey;

@implementation NSObject (DDAutoTracker)

- (NSDictionary *)ddInfoDictionary {
    return objc_getAssociatedObject(self, ddInfoDictionaryPropertyKey);
}

- (void)setDdInfoDictionary:(NSDictionary *)ddInfoDictionary {
    if (ddInfoDictionary) {
        objc_setAssociatedObject(self, ddInfoDictionaryPropertyKey, ddInfoDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


- (NSDictionary *)UIControlInfoDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self isKindOfClass: UISwitch.class]) {
        dict[@"switch_on"] = @([(UISwitch *)self isOn]);
    } else if ([self isKindOfClass: UISlider.class]) {
        dict[@"slider_value"] = @([(UISlider *)self value]);
    } else if ([self isKindOfClass: UIButton.class]) {
        UIButton *btn = (UIButton *)self;
        dict[@"button_selected"] = @(btn.isSelected);
        if (btn.currentTitle.length) {
            dict[@"button_title"] = btn.currentTitle;
        }
    }
    return dict;
}

- (void)configInfoData:(id)obj {
    if (nil == obj) {
        return;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.ddInfoDictionary = obj;
    }else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        unsigned count;
        objc_property_t *properties = class_copyPropertyList([obj class], &count);
        
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            if (key.length > 0 &&
                [obj valueForKey:key]) {
                [dict setObject:[obj valueForKey:key] forKey:key];
            }
        }
        
        free(properties);
        
        if (dict) {
            self.ddInfoDictionary = dict;
        }
    }
}

@end
