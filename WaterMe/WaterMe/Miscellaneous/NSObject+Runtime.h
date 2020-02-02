//
//  NSObject+Runtime.h
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

@import Foundation;

@interface NSObject (Runtime)

/**
There is no way to guarantee that an object you don't control will or won't be
KVC compliant for a given key ahead of time. However, this method attempts
to do some introspection to see if it COULD work.

1. Checks for a matching selector
2. Checks the properties of the class to see if one matches
3. Checks the Ivars of the class to see if one matches

It goes in the above order and if one matches then it returns YES.
If all tests fail, it returns NO
 */
- (BOOL)sanityCheckForKey:(NSString*_Nonnull)key;

@end
