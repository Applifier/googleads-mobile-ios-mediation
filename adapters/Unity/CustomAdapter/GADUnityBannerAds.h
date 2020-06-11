//
//  GADUnityBannerAds.h
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/5/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UnityAds/UnityAds.h>

@interface GADUnityBannerAds : NSObject<UADSBannerViewDelegate>

/// Initializes a new instance with |connector| and |adapter|.
- (nonnull instancetype)initWithGADMAdNetworkConnector:(nonnull id<GADMAdNetworkConnector>)connector
                                               adapter:(nonnull id<GADMAdNetworkAdapter>)adapter
NS_DESIGNATED_INITIALIZER;

/// Loads a banner ad for a given adSize.
- (void)loadBannerWithSize:(GADAdSize)adSize;

/// Stops the receiver from delegating any notifications from Unity Ads.
- (void)stopBeingDelegate;
@end

