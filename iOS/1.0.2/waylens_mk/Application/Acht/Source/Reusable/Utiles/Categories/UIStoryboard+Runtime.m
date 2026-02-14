//
//  UIStoryboard+Runtime.m
//  Hachi
//
//  Created by lzhu on 6/27/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UIStoryboard+Runtime.h"
#import <objc/runtime.h>

@implementation UIStoryboard (Runtime)

+ (UIViewController*) viewControllerWithIdentifier:(NSString *)idnetifier {
    NSAssert(idnetifier != nil, @"Parameter \'Identifier\' Can't be nil.");
    static dispatch_once_t once;
    static NSMutableDictionary *storyboardmap = nil;
    dispatch_once(&once, ^{
        storyboardmap = [NSMutableDictionary dictionaryWithCapacity:128];
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *storyborads = [bundle pathsForResourcesOfType:@"storyboardc" inDirectory:@""];
        for(NSString *sb in storyborads) {
            NSString *name = [[sb lastPathComponent] stringByDeletingPathExtension];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
            Ivar var = class_getInstanceVariable([UIStoryboard class], "identifierToNibNameMap");
            if(var != NULL) {
                NSDictionary *value = object_getIvar(storyboard, var);
                if(value == nil) continue;
                NSArray *identifiers = value.keyEnumerator.allObjects;
                for(NSString *ID in identifiers) {
                    if(storyboardmap[ID]) {
                        NSString *msg = [NSString stringWithFormat:@"Same UIViewController Identifier %@  in UIStoryboard <%@> and UIStoryboard <%@>", storyboardmap[ID], name, ID];
                        NSAssert(0, msg);
                    }
                    storyboardmap[ID] = name;
                }
            }
        }
    });
    NSString *sb = storyboardmap[idnetifier];
    if(sb) {
        return [[UIStoryboard storyboardWithName:sb bundle:nil] instantiateViewControllerWithIdentifier:idnetifier];
    }
    return nil;
}

@end
