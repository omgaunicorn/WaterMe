//
//  CatcherCollectionView.m
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

#import "CatcherCollectionViewController.h"

@implementation CatcherCollectionViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self replaceCollectionView];
}

- (void)replaceCollectionView;
{
    UICollectionViewLayout* layout = self.collectionViewLayout; // [[UICollectionViewFlowLayout alloc] init]
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self configureCollectionView];
}

- (void)configureCollectionView;
{}

- (void)performBatchUpdates:(void (^)(void))updates
                        completion:(void (^)(BOOL))completion
                       shouldCatch: (BOOL (^)(NSException*)) catch;
{
    @try {
        [self.collectionView performBatchUpdates:updates completion:completion];
    } @catch(NSException* e) {
        BOOL shouldCatch = catch(e);
        if (!shouldCatch) {
            @throw e;
        } else {
            @try {
                [self replaceCollectionView];
            } @catch(NSException* e) {
                // we know this will throw an exception and we can just ignore, we're already down this horrible path
            }
        }
    }
}

@end
