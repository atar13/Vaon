
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

@interface BCBatteryDevice : NSObject
@property (nonatomic, assign) BOOL fake;
@property(nonatomic, readonly) UIImage *glyph;
- (long long)percentCharge;
- (BOOL)isBatterSaveModeActive;
- (BOOL)isCharging;
- (BOOL)_lowBattery;
- (NSString*)identifier;
- (NSString*)name;
@end



@interface BCBatteryDeviceController : NSObject
+ (id)sharedInstance;
- (NSArray*)connectedDevices;
-(void)_queue_addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;
@end


@interface VaonDeviceBatteryCell : UIStackView
    -(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device;
    @property (nonatomic, weak) BCBatteryDevice *device;
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
    -(CGFloat)getCellWidth;
    -(void)setCellWidth:(CGFloat)arg1;
    -(void)addPercentageSymbolToLabel;
    -(long long)getDevicePercentage;
    -(void)updateDevicePercentage;
    -(void)updateCircleOutline;
    -(void)updateDevicePercentageLabel;
    -(void)animateOutlineLayer:(CGFloat)progress;
    -(void)resetStrokeEnd;
    -(void)removeFromSuperview;
    -(CGFloat)devicePercentageAsProgress;
@end
