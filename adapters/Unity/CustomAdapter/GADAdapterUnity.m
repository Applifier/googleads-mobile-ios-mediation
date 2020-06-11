//
//  GADAdapterUnity.m
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/8/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//

#import "GADAdapterUnity.h"

#import "GADMAdapterUnityConstants.h"
#import "GADAdapterUnityRouter.h"
#import "GADMediationAdapterUnity.h"
#import "GADUnityError.h"
#import "GADUnityBannerAds.h"
#import "GADUnityInterstitialAds.h"

@implementation GADAdapterUnity{
  /// Connector from Google Mobile Ads SDK to receive ad configurations.
  __weak id<GADMAdNetworkConnector> _connector;

  /// Facebook Audience Network banner ad wrapper.
  GADUnityBannerAds *_bannerAd;
  /// Facebook Audience Network interstitial ad wrapper.
  GADUnityInterstitialAds *_interstitialAd;
    
}

+ (nonnull Class<GADMediationAdapter>)mainAdapterClass {
  return [GADMediationAdapterUnity class];
}

+ (NSString *)adapterVersion {
  return kGADMAdapterUnityVersion;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
  return Nil;
}
#pragma mark Interstitial Methods

- (instancetype)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)connector {
  if (!connector) {
    return nil;
  }
  self = [super init];
  if (self) {
    _connector = connector;
  }
  return self;
}


- (void)getInterstitial {
   id<GADMAdNetworkConnector> strongConnector = _connector;
    _interstitialAd = [[GADUnityInterstitialAds alloc] initWithGADMAdNetworkConnector:strongConnector adapter:self];
    [_interstitialAd getInterstitial];
}

- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [_connector adapterWillPresentInterstitial:self];
    [_interstitialAd presentInterstitialFromRootViewController:rootViewController];
}

#pragma mark Banner Methods

- (void)getBannerWithSize:(GADAdSize)adSize {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  _bannerAd = [[GADUnityBannerAds alloc] initWithGADMAdNetworkConnector:strongConnector
                                                                       adapter:self];
  [_bannerAd loadBannerWithSize:adSize];
}

- (void)stopBeingDelegate {
  [_bannerAd stopBeingDelegate];
  _interstitialAd = nil;
}

@end
