//
//  NSObject+Runtime.m
//  WaterMe
//
//  Created by Jeffrey Bergier on 2020/02/02.
//  Copyright © 2020 Saturday Apps. All rights reserved.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

#import "NSObject+Runtime.h"
@import ObjectiveC.runtime;

@implementation NSObject (Runtime)

- (BOOL)sanityCheckForKey:(NSString*)key;
{
    // 1. Check if we have a selector. If so, KVC will probably work.
    if ([self respondsToSelector:@selector(key)]) {
        return YES;
    }

    // 2. Check properties for a match, if so KVC will probably work.
    NSArray<NSString*>* properties = [self __classPropertyList];
    if ([properties containsObject:key]) {
        return YES;
    }

    // 3. Check Ivars for a match. This is last ditch effort to sanity check
    NSArray<NSString*>* ivars = [self __classIvarList];
    if ([ivars containsObject:key]) {
        return YES;
    }

    return NO;
}

- (NSArray<NSString*>*)__classIvarList;
{
    id LenderClass = object_getClass(self);
    unsigned int outCount, i;
    Ivar* ivars = class_copyIvarList(LenderClass, &outCount);
    NSMutableArray* ivarNames = [NSMutableArray new];
    for (i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        const char* _name = ivar_getName(ivar);
        NSString* name = [NSString stringWithCString:_name encoding:NSUTF8StringEncoding];
        if (name) {
            [ivarNames addObject:name];
        }
    }
    return [ivarNames copy];
}

- (NSArray<NSString*>*)__classPropertyList;
{
    id LenderClass = object_getClass(self);
    unsigned int outCount, i;
    objc_property_t* properties = class_copyPropertyList(LenderClass, &outCount);
    NSMutableArray* propertyNames = [NSMutableArray new];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char* _name = property_getName(property);
        NSString* name = [NSString stringWithCString:_name encoding:NSUTF8StringEncoding];
        if (name) {
            [propertyNames addObject:name];
        }
    }
    return [propertyNames copy];
}

@end
