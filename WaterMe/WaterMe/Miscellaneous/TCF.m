//
//  TCF.m
//  Catcher
//
//  Created by Jeffrey Bergier on 03/04/2018.
//  Copyright © 2018 Saturday Apps.
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

#import "TCF.h"

@implementation TCF

+ (void)    try: (void (^ _Nonnull)(void)) try
    shouldCatch: (BOOL (^ _Nullable)(NSException* _Nonnull)) catch
        finally: (void (^ _Nullable)(BOOL)) finally;
{
    BOOL caught = NO;
    @try {
        if (try == nil) { return; }
        try();
    }
    @catch(NSException* e) {
        if (catch == nil) {
            @throw e;
            return;
        }
        BOOL shouldCatch = catch(e);
        if (!shouldCatch) {
            @throw e;
            return;
        }
        caught = YES;
    }
    @finally {
        if (finally == nil) { return; }
        finally(caught);
    }
}

@end
