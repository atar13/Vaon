#import <Cephei/HBPreferences.h>
#import <Vaon.h>
#import <QuartzCore/QuartzCore.h>


HBPreferences *prefs;

//preference variables
BOOL isEnabled;
NSString *switcherMode = nil;
NSString *selectedModule = nil;
BOOL hideAppTitles;
BOOL hideSuggestionBanner;
BOOL customHeightEnabled;
CGFloat customHeight;
BOOL customWidthEnabled;
CGFloat customWidth;
BOOL customVerticalOffsetEnabled;
CGFloat customVerticalOffset;

BOOL hideInternal;
BOOL hidePercent;
BOOL roundOutlineCorners;
BOOL pulsateChargingOutline;
BOOL keepDisconnectedDevices;
BOOL customBatteryCellSizeEnabled;
CGFloat customBatteryCellSize; 
BOOL customPercentageFontSizeEnabled;
CGFloat customPercentageFontSize;

UIView *vaonView;
UIView *vaonGridView;

UIScrollView *batteryScrollView;

UIStackView *batteryHStackView;
// UIScrollView *favoriteContactsScrollView;
UIStackView *favoriteContactsHStackView;

UIColor *vaonViewBackgroundColor;
UIVisualEffectView *vaonBlurView;
UIBlurEffect *blurEffect;
UILabel *titleLabel;

int vaonViewCornerRadius = 17;

CGFloat dockWidth;
BOOL vaonViewIsInitialized = FALSE;

// long long sbAppSwitcherOrientation;
SBMainSwitcherViewController *mainAppSwitcherVC;
long long customSwitcherStyle;
long long currentSwitcherStyle;
BOOL appSwitcherOpen = FALSE;
int fadeInCounter = 0;
BOOL doneFadingIn = FALSE;

//batteryView variables
NSArray *connectedBluetoothDevices;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];

UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;
-(long long)sbActiveInterfaceOrientation;
-(BOOL)isMainSwitcherVisible;
-(BOOL)isAnySwitcherVisible;
@end

@interface SBSwitcherAppSuggestionContentView : UIView
@end

@interface SBSwitcherAppSuggestionContentViewController : UIViewController 
@end

@interface SBFluidSwitcherViewController : UIViewController
@end

@interface SBAppSwitcherSettings
@property (assign) double spacingBetweenTrailingEdgeAndLabels;
@property (assign) double centerPoint;
@property (assign) long long switcherStyle;
-(long long)switcherStyle;
@end

@interface SBGridSwitcherViewController : SBFluidSwitcherViewController
@end

@interface PLPlatterview : UIView
@end

@interface SBSwitcherAppSuggestionBannerView : PLPlatterview
@end

@interface BCBatteryDevice : NSObject
@property (nonatomic, assign) BOOL fake;
@property(nonatomic, readonly) UIImage *glyph;
- (long long)percentCharge;
- (BOOL)isBatterySaverModeActive;
- (BOOL)isCharging;
- (BOOL)isLowBattery;
- (BOOL)isInternal;
- (NSString*)identifier;
- (NSString*)name;
- (BOOL)isConnected;
-(NSString *)accessoryIdentifier;
-(NSString *)groupName;
-(unsigned long long)parts;
-(BOOL)isFake;
@end



@interface BCBatteryDeviceController : NSObject
+ (id)sharedInstance;
- (NSArray*)connectedDevices;
-(void)_queue_addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;
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
    -(void)updateCircleOutline;
    -(void)updateDevicePercentageLabel;
    // -(void)animateOutlineLayer:(CGFloat)progress;
    -(void)resetStrokeEnd;
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

@interface PulsateColorAnimationDelegate :NSObject <CAAnimationDelegate>
-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell nextAnimation:(CAAnimation *)nextAnimation;
@property (nonatomic) VaonDeviceBatteryCell *cell;
@property (nonatomic, strong) CAAnimation *nextAnimation;
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
@end

@interface CNFavorites : NSObject
+(id)sharedInstance;
@property (nonatomic,readonly) NSArray * entries; 
@end

@interface CNContact : NSObject
-(NSData *)imageData;
@end

@interface CNFavoriteEntry : NSObject
-(NSString *)originalName;
-(CNContact *)contact;
@end

@interface VaonFavoriteContactsCell : UIStackView
-(instancetype)initWithFrame:(CGRect)arg1 favoriteEntry:(CNFavoriteEntry *)favoriteEntry;
@property (nonatomic, strong) CNFavoriteEntry *favoriteEntry;
@property (nonatomic, strong) CNContact *contact;
// @property (nonatomic, strong) NSString *originalName;
// @property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) UILabel *contactNameLabel;
@property (nonatomic, strong) UIImageView *contactImageView;
@end

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
