//
//  GADUnityBannerAds.m
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/5/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//
#import "GADUnityBannerAds.h"
#import "GADMAdapterUnityConstants.h"
#import "GADMAdapterUnitySingleton.h"
#import "GADMediationAdapterUnity.h"
#import "GADUnityError.h"
@implementation GADUnityBannerAds {
    /// Connector from Google Mobile Ads SDK to receive ad configurations.
    __weak id<GADMAdNetworkConnector> _connector;

    /// Adapter for receiving ad request notifications.
    __weak id<GADMAdNetworkAdapter> _adapter;
    
    /// Unity Ads banner ad object.
    UADSBannerView *_bannerAd;

    /// Unity ads placement ID.
    NSString *_placementID;
}


- (nonnull instancetype)initWithGADMAdNetworkConnector:(nonnull id<GADMAdNetworkConnector>)connector
                                               adapter:(nonnull id<GADMAdNetworkAdapter>)adapter {
  self = [super init];
  if (self) {
    _adapter = adapter;
    _connector = connector;

  }
  return self;
}

- (void)loadBannerWithSize:(GADAdSize)adSize {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;

  if (!strongConnector || !strongAdapter) {
    NSLog(@"Adapter Error: No GADMAdNetworkConnector or GADMAdNetworkAdapter found.");
    return;
  }

  if (![UnityAds isInitialized]) {
    NSString *gameID = [strongConnector.credentials[kGADMAdapterUnityGameID] copy];
    [GADMAdapterUnitySingleton.sharedInstance initializeWithGameID:gameID];
  }

  _placementID = [strongConnector.credentials[kGADMAdapterUnityPlacementID] copy];
  _bannerAd = [[UADSBannerView alloc] initWithPlacementId:_placementID size:adSize.size];

  if (!_bannerAd) {
    NSError *error = GADUnityErrorWithDescription(@"Unity banner failed to initialize.");
    [strongConnector adapter:strongAdapter didFailAd:error];
    return;
  }

  _bannerAd.delegate = self;
  [_bannerAd load];
}

- (void)stopBeingDelegate {
    _bannerAd = nil;
    _bannerAd.delegate = nil;
}

#pragma mark UADSBannerView Delegate methods

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongConnector && strongAdapter) {
    [strongConnector adapter:strongAdapter didReceiveAdView:bannerView];
  }
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongAdapter && strongConnector) {
    [strongConnector adapterDidGetAdClick:strongAdapter];
  }
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongAdapter && strongConnector) {
    [strongConnector adapterWillLeaveApplication:strongAdapter];
  }
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongConnector && strongAdapter) {
    NSString *errorMsg =
        [NSString stringWithFormat:@"Unity Ads banner failed to load with error: %@",
                                   error.localizedDescription];
    [strongConnector adapter:strongAdapter didFailAd:GADUnityErrorWithDescription(errorMsg)];
  }
}

@end
