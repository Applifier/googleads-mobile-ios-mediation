//
//  GADAdapterUnityRouter.h
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/5/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//
// Connects the adapter to UnityAdsSDK
@import Foundation;
@import GoogleMobileAds;
@import UnityAds;

#import "GADMAdapterUnityProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADAdapterUnityRouter : NSObject

- (id)initializeWithGameID:(NSString *)gameID;

/// Requests a reward-based video ad with |adapterDelegate|.
- (void)requestRewardedAdWithDelegate:
    (id<GADMAdapterUnityDataProvider, UnityAdsExtendedDelegate>)adapterDelegate;

/// Presents a reward-based video ad for |viewController| with |adapterDelegate|.
- (void)presentRewardedAdForViewController:(UIViewController *)viewController
                                  delegate:
                                      (id<GADMAdapterUnityDataProvider, UnityAdsExtendedDelegate>)
                                          adapterDelegate;

/// Configures an interstitial ad with provided |gameID| and |adapterDelegate|.
- (void)requestInterstitialAdWithDelegate:
    (id<GADMAdapterUnityDataProvider, UnityAdsExtendedDelegate>)adapterDelegate;

/// Presents an interstitial ad for |viewController| with |adapterDelegate|.
- (void)presentInterstitialAdForViewController:(UIViewController *)viewController
                                      delegate:(id<GADMAdapterUnityDataProvider,
                                                   UnityAdsExtendedDelegate>)adapterDelegate;

/// Tells the adapter to remove itself as a |adapterDelegate|.
- (void)stopTrackingDelegate:
    (id<GADMAdapterUnityDataProvider, UnityAdsExtendedDelegate>)adapterDelegate;
@end

NS_ASSUME_NONNULL_END
