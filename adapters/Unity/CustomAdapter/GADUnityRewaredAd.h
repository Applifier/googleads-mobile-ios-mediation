//
//  GADUnityRewaredAd.h
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/9/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMobileAds;

@interface GADUnityRewaredAd : NSObject<GADMediationRewardedAd>

- (instancetype)initWithAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationRewardedLoadCompletionHandler)completionHandler;

/// Requests GADAdapterUnityRouter to fetch Rewarded Ad
- (void)requestRewardedAd;

/// Requests GADAdapterUnityRouter to present Rewarded Ad
- (void)presentFromViewController:(nonnull UIViewController *)viewController;
@end


