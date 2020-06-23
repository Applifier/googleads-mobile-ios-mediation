//
//  GADMUnityInterstitialAd.m
//  AdMob-TestApp-Local
//
//  Created by Kavya Katooru on 6/10/20.
//  Copyright © 2020 Unity Ads. All rights reserved.
//

#import "GADMUnityInterstitialAd.h"
#import "GADMAdapterUnityConstants.h"
#import "GADUnityError.h"

@interface GADMUnityInterstitialAd () <GADMAdapterUnityDataProvider, UnityAdsExtendedDelegate, UnityAdsLoadDelegate>

@end
@implementation GADMUnityInterstitialAd {
    NSString *_placementID;
    NSString *_gameID;
    BOOL _isLoading;
/// Connector from Google Mobile Ads SDK to receive ad configurations.
    __weak id<GADMAdNetworkConnector> _connector;

    /// Adapter for receiving ad request notifications.
    __weak id<GADMAdNetworkAdapter> _adapter;
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

- (void)getInterstitial {
    // This method loads interstitial Ads for a given _placementID
    id<GADMAdNetworkConnector> strongConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (!strongConnector || !strongAdapter) {
        return;
    }
    _gameID = [[[strongConnector credentials] objectForKey:kGADMAdapterUnityGameID] copy];
    _placementID = [[[strongConnector credentials] objectForKey:kGADMAdapterUnityPlacementID] copy];
    if (!_gameID || !_placementID) {
        NSError *error = GADUnityErrorWithDescription(@"Game ID and Placement ID cannot be nil.");
        [strongConnector adapter:strongAdapter didFailAd:error];
        return;
    }
    _isLoading = YES;
//    [UnityAds load:_placementID];
    [UnityAds load:_placementID loadDelegate:self];
}

- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
    //This method shows the Ad and is followed by unityAdsDidFinish callback when the Ad is finished.
  // We will send adapterWillPresentInterstitial callback before presenting unity ad because the ad
  // has already loaded.
    id<GADMAdNetworkConnector> strongConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    [strongConnector adapterWillPresentInterstitial:strongAdapter];
    if ([UnityAds isReady:_placementID]) {
        [UnityAds show:rootViewController placementId:_placementID];
    }
}
#pragma mark GADMAdapterUnityDataProvider Methods

- (NSString *)getGameID {
  return _gameID;
}

- (NSString *)getPlacementID {
  return _placementID;
}

- (void)didFailToLoadWithError:(nonnull NSError *)error { 
    id<GADMAdNetworkConnector> strongConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (strongConnector != nil && strongAdapter != nil) {
      [strongConnector adapter:strongAdapter didFailAd:error];
    }
}

#pragma mark - Unity Delegate Methods

- (void)unityAdsPlacementStateChanged:(NSString *)placementId
                             oldState:(UnityAdsPlacementState)oldState
                             newState:(UnityAdsPlacementState)newState {
  // This callback is not forwarded to the adapter by the GADMAdapterUnitySingleton and the adapter
  // should use the unityAdsReady: and unityAdsDidError: callbacks to forward Unity Ads SDK state to
  // Google Mobile Ads SDK.
}

- (void)unityAdsDidFinish:(NSString *)placementID withFinishState:(UnityAdsFinishState)state {
    // Called when the Ad s finished showing.
    id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (strongNetworkConnector && strongAdapter) {
        [strongNetworkConnector adapterWillDismissInterstitial:strongAdapter];
        [strongNetworkConnector adapterDidDismissInterstitial:strongAdapter];
    }
}

- (void)unityAdsDidClick:(NSString *)placementID {
    // Called when user clicks on the Ad.
      // The Unity Ads SDK doesn't provide an event for leaving the application, so the adapter assumes
      // that a click event indicates the user is leaving the application for a browser or deeplink, and
      // notifies the Google Mobile Ads SDK accordingly.
    id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (strongNetworkConnector && strongAdapter) {
        [strongNetworkConnector adapterDidGetAdClick:strongAdapter];
        [strongNetworkConnector adapterWillLeaveApplication:strongAdapter];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    // Unity Ads show error will only happen after the ad has been loaded. So, we will send
    // dismiss/close callbacks.
    id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (!_isLoading) {
        if (error == kUnityAdsErrorShowError) {
            if (strongNetworkConnector && strongAdapter) {
                [strongNetworkConnector adapterWillDismissInterstitial:strongAdapter];
                [strongNetworkConnector adapterDidDismissInterstitial:strongAdapter];
            }
        }
        return;
  }

    NSError *errorWithDescription = GADUnityErrorWithDescription(message);
    if (strongNetworkConnector && strongAdapter) {
        [strongNetworkConnector adapter:strongAdapter didFailAd:errorWithDescription];
    }
    _isLoading = NO;
}

- (void)unityAdsDidStart:(nonnull NSString *)placementId {
  // nothing to do
}

- (void)unityAdsReady:(nonnull NSString *)placementId {
    // nothing to do
}


// UnityAdsLoadDelegate methods

- (void)unityAdsAdFailedToLoad:(nonnull NSString *)placementId {
    //called when the Ad is failed to load the Ad.
    id<GADMAdNetworkConnector> strongConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (strongConnector && strongAdapter) {
        NSError *error = GADUnityErrorWithDescription(@"unityAdsAdFailedToLoad");
        [strongConnector adapter:strongAdapter didFailAd:error];
    }
}

- (void)unityAdsAdLoaded:(nonnull NSString *)placementId {
    //called when the Ad is loaded successfully.
    id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
    id<GADMAdNetworkAdapter> strongAdapter = _adapter;
    if (!_isLoading) {
        return;
    }
    if (strongNetworkConnector && strongAdapter) {
        [strongNetworkConnector adapterDidReceiveInterstitial:strongAdapter];
    }
    _isLoading = NO;
}

@end
