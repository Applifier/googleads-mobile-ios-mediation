//
//  GADMediationAdapterU.m
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/9/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//

#import "GADMediationAdapterU.h"
#import "GADMAdapterUnityConstants.h"
#import "GADUnityRewaredAd.h"
#import "GADAdapterUnityRouter.h"
#import "GADMAdapterUnityUtils.h"
#import "GADUnityError.h"
@implementation GADMediationAdapterU

// Called on Admob->init
+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    
    NSMutableSet *gameIDs = [[NSMutableSet alloc] init];
    for (GADMediationCredentials *cred in configuration.credentials) {
        NSString *gameIDFromSettings = cred.settings[kGADMAdapterUnityGameID];
        GADMAdapterUnityMutableSetAddObject(gameIDs, gameIDFromSettings);
    }
    
    if (!gameIDs.count) {
        NSError *errorWithDescription = GADUnityErrorWithDescription(
                                                                     @"UnityAds mediation configurations did not contain a valid game ID.");
        completionHandler(errorWithDescription);
        return;
    }
    
    NSString *gameID = [gameIDs anyObject];
    if (gameIDs.count > 1) {
        NSLog(@"Found the following game IDs: %@. "
              @"Please remove any game IDs you are not using from the AdMob UI.",
              gameIDs);
        NSLog(@"Initializing Unity Ads SDK with the game ID %@.", gameID);
    }
    [[GADAdapterUnityRouter alloc] initializeWithGameID:gameID];
    completionHandler(nil);
}

+ (GADVersionNumber)adSDKVersion {
    GADVersionNumber version = {0};
    NSString *sdkVersion = [UnityAds getVersion];
    NSArray<NSString *> *components = [sdkVersion componentsSeparatedByString:@"."];
    if (components.count == 3) {
      version.majorVersion = components[0].integerValue;
      version.minorVersion = components[1].integerValue;
      version.patchVersion = components[2].integerValue;
    } else {
      NSLog(@"Unexpected Unity Ads version string: %@. Returning 0 for adSDKVersion.", sdkVersion);
    }
    return version;
}


+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}


+ (GADVersionNumber)version {
    GADVersionNumber version = {0};
    NSString *adapterVersion = kGADMAdapterUnityVersion;
    NSArray<NSString *> *components = [adapterVersion componentsSeparatedByString:@"."];
    if (components.count >= 4) {
      version.majorVersion = components[0].integerValue;
      version.minorVersion = components[1].integerValue;
      version.patchVersion = components[2].integerValue * 100 + components[3].integerValue;
    }
    return version;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    
}

- (void)loadInterstitialAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
  
}
- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
  
}


@end
