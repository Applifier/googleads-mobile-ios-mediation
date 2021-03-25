// Copyright 2020 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GADMAdapterUnityRewardedAd.h"
#import "GADMAdapterUnity.h"
#import "GADMAdapterUnityConstants.h"
#import "GADMAdapterUnityUtils.h"
#import "GADUnityError.h"

@interface GADMAdapterUnityRewardedAd () <GADMediationRewardedAd, UnityAdsLoadDelegate>
@end

@implementation GADMAdapterUnityRewardedAd {
  /// The completion handler to call when the ad loading succeeds or fails.
  GADMediationRewardedLoadCompletionHandler _adLoadCompletionHandler;

  /// Ad configuration for the ad to be rendered.
  GADMediationAdConfiguration *_adConfiguration;

  /// An ad event delegate to invoke when ad rendering events occur.
  id<GADMediationRewardedAdEventDelegate> _adEventDelegate;

  /// Placement ID of Unity Ads network.
  NSString *_placementID;

  /// Serial dispatch queue.
  dispatch_queue_t _lockQueue;
}

/// A map to keep track loaded Placement IDs
static NSMapTable<NSString *, GADMAdapterUnityRewardedAd *> *_placementInUseRewarded;

- (instancetype)initWithAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationRewardedLoadCompletionHandler)completionHandler {
  self = [super init];
  if (self) {
    _adLoadCompletionHandler = completionHandler;
    _adConfiguration = adConfiguration;
    _placementInUseRewarded = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                    valueOptions:NSPointerFunctionsWeakMemory];
    _lockQueue = dispatch_queue_create("unityAds-rewardedAd", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)requestRewardedAd {
  NSString *gameID = _adConfiguration.credentials.settings[kGADMAdapterUnityGameID];
  _placementID = _adConfiguration.credentials.settings[kGADMAdapterUnityPlacementID];

  NSLog(@"Requesting Unity rewarded ad with placement: %@", _placementID);
  if (!gameID || !_placementID) {
    if (_adLoadCompletionHandler) {
      NSError *error = GADMAdapterUnityErrorWithCodeAndDescription(
          GADMAdapterUnityErrorInvalidServerParameters, @"Game ID and Placement ID cannot be nil.");
      _adLoadCompletionHandler(nil, error);
      _adLoadCompletionHandler = nil;
    }
    return;
  }

  if (![UnityAds isInitialized]) {
    [[GADMAdapterUnity alloc] initializeWithGameID:gameID withCompletionHandler:nil];
  }

  __block GADMAdapterUnityRewardedAd *rewardedAd = nil;
  dispatch_sync(_lockQueue, ^{
    rewardedAd = [_placementInUseRewarded objectForKey:_placementID];
  });

  if (rewardedAd) {
    if (_adLoadCompletionHandler) {
      NSError *error = GADUnityErrorWithDescription([NSString
          stringWithFormat:@"An ad is already loading for placement ID: %@.", _placementID]);
      _adEventDelegate = _adLoadCompletionHandler(nil, error);
    }
    return;
  }

  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableSetObjectForKey(_placementInUseRewarded, self->_placementID, self);
  });

  [UnityAds load:_placementID loadDelegate:self];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableRemoveObjectForKey(_placementInUseRewarded, self->_placementID);
  });

  [_adEventDelegate willPresentFullScreenView];
  [UnityAds show:viewController placementId:_placementID showDelegate:self];
}

- (void)cleanup {
  _adEventDelegate = nil;
  _adLoadCompletionHandler = nil;
}

#pragma mark - UnityAdsLoadDelegate Methods

- (void)unityAdsAdLoaded:(nonnull NSString *)placementId {
  if (_adLoadCompletionHandler) {
    _adEventDelegate = _adLoadCompletionHandler(self, nil);
  }
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(NSString *)message {
  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableRemoveObjectForKey(_placementInUseRewarded, self->_placementID);
  });

  if (_adLoadCompletionHandler) {
    NSError *error = GADUnityErrorWithDescription([NSString
        stringWithFormat:@"Failed to load rewarded ad with placement ID '%@'", placementId]);
    _adEventDelegate = _adLoadCompletionHandler(nil, error);
  }
  [self cleanup];
}

#pragma mark - UnityAdsShowDelegate Methods

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
  [_adEventDelegate didStartVideo];
}

- (void)unityAdsShowClick:(NSString *)placementId {
  // The Unity Ads SDK doesn't provide an event for leaving the application, so the adapter assumes
  // that a click event indicates the user is leaving the application for a browser or deeplink, and
  // notifies the Google Mobile Ads SDK accordingly.
  [_adEventDelegate reportClick];
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
  [_adEventDelegate didEndVideo];

  if (state == kUnityAdsFinishStateCompleted) {
    // Unity Ads doesn't provide a way to set the reward on their front-end. Default to a reward
    // amount of 1. Publishers using this adapter should override the reward on the AdMob
    // front-end.
    GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@""
                                                     rewardAmount:[NSDecimalNumber one]];
    [_adEventDelegate didRewardUserWithReward:reward];
  }

  [_adEventDelegate willDismissFullScreenView];
  [_adEventDelegate didDismissFullScreenView];
  [self cleanup];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
  NSError *errorWithDescription =
      GADMAdapterUnitySDKErrorWithUnityAdsShowErrorAndMessage(error, message);
  [_adEventDelegate didFailToPresentWithError:errorWithDescription];
  [self cleanup];
}

@end
