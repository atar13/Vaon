#import <Cephei/HBPreferences.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

//works for iOS 13 and 14
@interface SBMainSwitcherViewController : UIViewController
+(id)sharedInstance;
-(long long)sbActiveInterfaceOrientation;
-(BOOL)isMainSwitcherVisible;
-(BOOL)isAnySwitcherVisible;
-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3;
-(void)_updateDisplayLayoutElementForLayoutState:(id)arg1 ;
@end

//works for iOS 13 and 14
@interface SBSwitcherAppSuggestionContentView : UIView
@end


//works for iOS 13
// @interface SBSwitcherAppSuggestionContentViewController : UIViewController 
// @end

//works for iOS 13 and 14
@interface SBFluidSwitcherViewController : UIViewController
@end

//works for iOS 13 and 14
@interface SBAppSwitcherSettings
@property (assign) double spacingBetweenTrailingEdgeAndLabels;
@property (assign) double centerPoint;
@property (assign) long long switcherStyle;
-(long long)switcherStyle;
@end

//works for iOS 13 and 14
@interface SBGridSwitcherViewController : SBFluidSwitcherViewController
@end

//works for iOS 13 and 14
@interface PLPlatterview : UIView
@end

//works for iOS 13 and 14
@interface SBSwitcherAppSuggestionBannerView : PLPlatterview
@end

//works in iOS 13 but glyph doesn't work in iOS 14
@interface BCBatteryDevice : NSObject
@property (assign,getter=isFake,nonatomic) BOOL fake; 
//ONLY IN IOS 13
@property (nonatomic,readonly) UIImage * glyph; 
//ONLY IN IOS 14
-(id)batteryWidgetGlyph;
-(long long)percentCharge;
-(BOOL)isBatterySaverModeActive;
-(BOOL)isCharging;
-(BOOL)isLowBattery;
-(BOOL)isInternal;
-(NSString *)identifier;
-(NSString *)name;
-(BOOL)isConnected;
-(NSString *)accessoryIdentifier;
-(NSString *)groupName;
-(unsigned long long)parts;
-(BOOL)isFake;
-(void)setPercentCharge:(long long)arg1;
-(void)updateScrollWidthAndTouchPassthrough;
@end

@interface BCBatteryDeviceController : NSObject
+(id)sharedInstance;
-(NSArray *)connectedDevices;
@property (setter=_setSortedDevices:,getter=_sortedDevices,nonatomic,retain) NSArray * sortedDevices;                                                 
// -(id)_sortedDevices;
//only supported on iOS 13
-(void)removeDeviceChangeHandlerWithIdentifier:(id)arg1;
@end

@interface VaonDeviceBatteryCell : UIStackView 
-(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device;
@property (nonatomic, weak) BCBatteryDevice *device;
@property (nonatomic) BOOL disconnected;
@property (nonatomic) CGFloat lastKnownPercentage;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic) long long devicePercentage;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic, strong) UIView *circleBackgroundView;
@property (nonatomic, strong) UILabel *devicePercentageLabel;
@property (nonatomic, strong) UIBlurEffect *circleBackgroundBlurEffect;
@property (nonatomic, strong) UIVisualEffectView *circleBackgroundVisualEffectView;
@property (nonatomic, strong) NSMutableString *devicePercentageString;
@property (nonatomic, readonly, strong) UIFont *devicePercentageLabelFont;
@property (nonatomic, strong) UIBezierPath *circleOutlinePath;
@property (nonatomic, strong) CAShapeLayer *circleOutlineLayer;
@property (nonatomic, strong) UIImageView *deviceGlyphView;
@property (nonatomic, strong) CABasicAnimation *percentageAnimation;
-(CGFloat)getCellWidth;
-(void)setCellWidth:(CGFloat)arg1;
-(void)addPercentageSymbolToLabel;
-(long long)getDevicePercentage;
-(void)updateDevicePercentage;
-(void)updateDevicePercentageLabel;
-(void)removeFromSuperview;
-(CGFloat)devicePercentageAsProgress;
-(BOOL)isDeviceInternal;
-(BOOL)isLowPowerModeOn;
-(BOOL)isBatteryLow;
-(void)updateOutlineColor;
-(void)pulsateOutline;
-(void)updatePercentageColor;
-(void)newAnimateOuterLayerToCurrentPercentage;
-(void)newAnimateOuterLayerToZero;
@end

@interface StrokeEndAnimationDelegate : NSObject <CAAnimationDelegate>
-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell;
@property (nonatomic) VaonDeviceBatteryCell *cell;
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
@end

@interface PulsateColorAnimationDelegate : NSObject <CAAnimationDelegate>
-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell nextAnimation:(CAAnimation *)nextAnimation;
@property (nonatomic) VaonDeviceBatteryCell *cell;
@property (nonatomic, strong) CAAnimation *nextAnimation;
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
@end

@interface CNFavorites : NSObject
+(id)sharedInstance;
@property (nonatomic,readonly) NSArray * entries; 
@end

// @interface CNContact : NSObject
// -(NSData *)imageData;
// @end

// @interface CNFavoriteEntry : NSObject
// -(NSString *)originalName;
// -(CNContact *)contact;
// @end

// @interface VaonFavoriteContactsCell : UIStackView
// -(instancetype)initWithFrame:(CGRect)arg1 favoriteEntry:(CNFavoriteEntry *)favoriteEntry;
// @property (nonatomic, strong) CNFavoriteEntry *favoriteEntry;
// @property (nonatomic, strong) CNContact *contact;
// // @property (nonatomic, strong) NSString *originalName;
// // @property (nonatomic, strong) NSString *value;
// @property (nonatomic, strong) UILabel *contactNameLabel;
// @property (nonatomic, strong) UIImageView *contactImageView;
// @end

@interface SBFluidSwitcherContentView : UIView

@end

@interface SBFTouchPassThroughView : UIView
@end

@interface SBAppSwitcherPageView : UIView
@end

@interface SBFluidSwitcherItemContainer : SBFTouchPassThroughView 
@end

@interface SBReusableSnapshotItemContainer : SBFluidSwitcherItemContainer
@end

@interface SBFluidSwitcherItemContainerHeaderView : UIView
@end

@interface SBSwitcherWallpaperPageContentView : UIView
@end

@interface SBAppSwitcherReusableSnapshotView : SBSwitcherWallpaperPageContentView
@end

@interface SBFluidSwitcherTouchPassThroughScrollView : UIScrollView
@end

@interface BSUIScrollView : UIScrollView
@end

@interface SBAppSwitcherScrollView : BSUIScrollView
@end

@interface SBApplication
-(id)bundleIdentifier;
@end