//
//  DeclaredAgeRangeObjCWrapper.m
//  DeclaredAgeRangeObjC
//
//  Created by Chris Pimlott on 18/12/2025.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DeclaredAgeRangeObjCWrapper.h"
#import <DeclaredAgeRangeObjC/DeclaredAgeRangeObjC-Swift.h>

@implementation DeclaredAgeRangeObjCWrapper

+ (void)fetchAgeRangeWithMinimumAge:(NSInteger)minimumAge
                         maximumAge:(NSInteger)maximumAge
                     viewController:(nonnull UIViewController *)vc
                         completion:(nonnull void (^)(NSObject * _Nullable __strong, NSError * _Nullable __strong))completion {
    [DeclaredAgeRangeBridge fetchAgeRangeWithMinimumAge:minimumAge maximumAge:maximumAge vc:vc completion:completion];
}

@end
