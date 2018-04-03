//
//  CatcherCollectionView.h
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

#import <UIKit/UIKit.h>

@interface CatcherCollectionViewController : UICollectionViewController

/* USE WITH CAUTION
 
 This method wraps the normal UICollectionView `-performBatchUpdates::` method.
 If calling the method raises an exception from the collectionview, the `shouldCatch` block is called
 Return YES to catch the exception and attempt to recover from the crash
 Return NO to throw the exception and allow the application to crash as normal

 Note*
     When YES is returned from the `shouldCatch` block, this class takes care of recovering from the exception
     This requires replacing the UICollectionView. Replacing the collection view requires configuring it again
     Make sure you configure the collection view from scratch in `-configureCollectionView`
     as this method is automatically called after the collection view is replaced.

     The UICollectionViewFlowLayout object is not destroyed and is transferred to the new collection view.
*/
- (void) performBatchUpdates:(void (^)(void))updates // normal batch update signature
                  completion:(void (^)(BOOL))completion // normal batch update signature
                 shouldCatch: (BOOL (^)(NSException* _Nonnull)) catch; // give the chance for the subclass code to decide whether to catch the exception or not

/*
 This is the override point for configuring your UICollectionView.
 Note that the configuration from a storyboard or NIB is ignored because this collectionview is replaced.
 
 The default implementation of this method does nothing
*/
- (void) configureCollectionView;

@end
