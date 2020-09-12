@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;
-(long long)sbActiveInterfaceOrientation;
-(BOOL)isMainSwitcherVisible;
-(BOOL)isAnySwitcherVisible;
@end

@interface SBSwitcherAppSuggestionContentView : UIView
@end

@interface SBFluidSwitcherViewController : UIViewController
@end

@interface SBFluidSwitcherContentView : UIView
@end

@interface SBAppSwitcherSettings
@property (assign) double spacingBetweenTrailingEdgeAndLabels;
@property (assign) double centerPoint;
@property (assign) long long switcherStyle;
@end

@interface SBGridSwitcherViewController : SBFluidSwitcherViewController
@end

@interface PLPlatterview : UIView
@end

@interface SBSwitcherAppSuggestionBannerView : PLPlatterview
@end

@interface BCBatteryDeviceController : NSObject
+ (id)sharedInstance;
- (NSArray*)connectedDevices;
@end