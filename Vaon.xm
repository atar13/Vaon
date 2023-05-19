//TODO: 
//raise app switcher

//ios 14 1751.108 

//credit to Dogbert for the icon

#import "Vaon.h"
#import <UIKit/UIKit.h>
// #import <Foundation/Foundation.h>


NSUserDefaults *prefs;

BOOL ios13;
BOOL ios14;

//main page preference variables
BOOL isEnabled;
NSString *switcherMode = nil;
NSString *selectedModule = nil;
BOOL hideBackground;
BOOL hideAppTitles;
BOOL hideAppIcons;
BOOL hideSuggestionBanner;
BOOL displayWithNoApps;

NSString *backgroundMode = nil;

BOOL enableFlyInOut;
BOOL enableDelay;
CGFloat fadeInDelay;

BOOL customHeightEnabled;
CGFloat customHeight;
BOOL customWidthEnabled;
CGFloat customWidth;
BOOL customVerticalOffsetEnabled;
CGFloat customVerticalOffset;
BOOL customHorizontalOffsetEnabled;
CGFloat customHorizontalOffset;

BOOL customGridSwitcherAppSizeEnabled;
CGFloat customGridSwitcherAppSize;
BOOL customGridSwitcherSpacingEnabled;
CGFloat customGridSwitcherSpacing;

//battery configuration preference variables
BOOL hideInternal;
BOOL hidePercentageLabel;
BOOL hidePercent;
BOOL enableBoldPercentage;
BOOL roundOutlineCorners;
BOOL pulsateChargingOutline;
BOOL keepDisconnectedDevices;
NSString *batteryTextColor = nil;
NSString *customBatteryTextColor = nil;
NSString *batteryGlyphBackgroundMode = nil;
BOOL customDeviceGlyphSizeEnabled;
CGFloat customDeviceGlyphSize;
BOOL customBatteryCellSizeEnabled;
CGFloat customBatteryCellSize; 
BOOL customPercentageFontSizeEnabled;
CGFloat customPercentageFontSize;
BOOL paddingBetweenGlyphAndLabelEnabled;
CGFloat paddingBetweenGlyphAndLabel;
BOOL horizontalSpacingBetweenDevicesEnabled;
CGFloat horizontalSpacingBetweenDevices;

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
SBSwitcherAppSuggestionContentView *switcherContentView;
long long customSwitcherStyle;
long long currentSwitcherStyle;
BOOL appSwitcherOpen = FALSE;
BOOL doneFadingIn = FALSE;
BOOL stockHidden = TRUE;
BOOL enteredApp;

NSArray *connectedBluetoothDevices;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];
NSMutableArray *deviceIdentifiers = [[NSMutableArray alloc] init];

UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];
UIColor *lowPowerModeColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
UIColor *lowBatteryColor = [UIColor redColor];
UIColor *darkGrayColor = [UIColor colorWithRed:0.1746478873 green:0.2039215686 blue:0.1960784314 alpha: 1];

//timers to initiate animations
NSTimer *delayedFadeInTimer = nil;
NSTimer *delayedPulsateTimer = nil;


BOOL firstSlideIn = false;

NSString *customConnectedDeviceColorMode;
NSString *customConnectedDeviceColor;

NSString *customDisconnectedDeviceColorMode;
NSString *customDisconnectedDeviceColor;

NSString *customLowPowerColorMode;
NSString *customLowPowerColor;

NSString *customLowBatteryColorMode;
NSString *customLowBatteryColor;

NSString *customChargingColorMode;
NSString *customChargingColor;

UIColor* colorFromHexString(NSString *hexString) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//delegate for outline animation
@implementation StrokeEndAnimationDelegate 

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell {
		self = [super init];
		self.cell = cell;
		return self;
	}

	//keeps the outline at a static position when it finishes animating
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag && pulsateChargingOutline){
			[self.cell pulsateOutline];
		}
	}

@end

//delegate for charging devices' pulsating color animation 
@implementation PulsateColorAnimationDelegate

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell nextAnimation:(CAAnimation *)nextAnimation {
		self = [super init];
		self.cell = cell;
		self.nextAnimation = nextAnimation;
		return self;
	}
	
	//when the animation finishes change the color and start another pulsate animation
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag && pulsateChargingOutline){
			if([self.cell.device isCharging]){
				[self.cell.circleOutlineLayer addAnimation:self.nextAnimation forKey:kCATransition];
			}else{
				self.cell.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
			}			
		}
	}
@end

//Individual battery cell for each device
@implementation VaonDeviceBatteryCell

	//initialization
    -(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)connectedDevice {
        self.device = connectedDevice;
		self.disconnected = FALSE;
		if(customBatteryCellSizeEnabled){
        	self.cellWidth = CGFloat(customBatteryCellSize);
		} else {
			self.cellWidth = CGFloat(50);
		}
        self.devicePercentage = [connectedDevice percentCharge];

		//initialize view placement
        self = [super initWithFrame:arg1];
        self.axis = UILayoutConstraintAxisVertical;
        self.alignment = UIStackViewAlignmentCenter;
		if(paddingBetweenGlyphAndLabelEnabled){
			self.spacing = paddingBetweenGlyphAndLabel;
			if(paddingBetweenGlyphAndLabel > 0) {
				self.distribution = UIStackViewDistributionEqualSpacing;
			}
		} else {
			self.spacing = 10;
			self.distribution = UIStackViewDistributionEqualSpacing;
		}
        self.clipsToBounds = FALSE;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = FALSE;

    
		//initialize background blur effect
		if ([batteryGlyphBackgroundMode isEqualToString:@"system"]) {
			self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		} else if ([batteryGlyphBackgroundMode isEqualToString:@"dark"]) {
			self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
		} else if ([batteryGlyphBackgroundMode isEqualToString:@"light"]) {
			self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight];
		}
        self.circleBackgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:self.circleBackgroundBlurEffect];
        self.circleBackgroundVisualEffectView.layer.cornerRadius = self.cellWidth/2;
        self.circleBackgroundVisualEffectView.clipsToBounds = TRUE;
        self.circleBackgroundVisualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.circleBackgroundVisualEffectView.frame = self.bounds;
       	self.circleBackgroundVisualEffectView.contentMode = UIViewContentModeScaleAspectFill;

		//battery percentage label
        self.devicePercentageLabel = [[UILabel alloc] init];
        [self updateDevicePercentageLabel];
        [self addPercentageSymbolToLabel];

		//font customization
		UIFont *devicePercentageLabelFont = [[UIFont alloc] init];
		//custom font size from prefs
		UIFontWeight percentageFontWeight;
		if(enableBoldPercentage) {
			percentageFontWeight = UIFontWeightBold;
		} else {
			percentageFontWeight = UIFontWeightRegular;
		}
		if(customPercentageFontSizeEnabled){
        	devicePercentageLabelFont = [UIFont systemFontOfSize:customPercentageFontSize weight:percentageFontWeight];
		} else{
        	devicePercentageLabelFont = [UIFont systemFontOfSize:12 weight:percentageFontWeight];
		}
        self.devicePercentageLabel.font = devicePercentageLabelFont;
        self.devicePercentageLabel.frame = self.bounds;
		self.devicePercentageLabel.textColor = normalBatteryColor;
        // self.devicePercentageLabel.clipsToBounds = TRUE;

		// self.devicePercentageLabel.layoutMargins = UIEdgeInsetsMake(0, 0, -20, 0);
		// [self setLayoutMarginsRelativeArrangement:YES];
		// self.devicePercentageLabel.bounds = CGRectInset(self.devicePercentageLabel.frame, 0.0f, 1.0f);
		// self.devicePercentageLabel.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(100, 0, 0, 0);

		//view placement and constraints for background blur
        // [self.circleBackgroundVisualEffectView.contentView addSubview:self.devicePercentageLabel];
        self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.circleBackgroundVisualEffectView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self.circleBackgroundVisualEffectView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
		// self.circleBackgroundVisualEffectView.frame = self.circleBackgroundVisualEffectView.frame.inset() UIEdgeInsetsMake(0, 0, 10, 0);

		[self addArrangedSubview:self.circleBackgroundVisualEffectView];

		// if(paddingBetweenGlyphAndLabelEnabled) {
		// 	self.paddingView = [[UIView alloc] init];
		// 	[self.paddingView.heightAnchor constraintEqualToConstant: paddingBetweenGlyphAndLabel].active = TRUE;
		// 	[self.paddingView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
		// 	[self addArrangedSubview:self.paddingView];
		// }


		//view placement and constrains for battery percentage 
        // self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
        // [self.devicePercentageLabel.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        // [self.devicePercentageLabel.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor constant:100].active = TRUE;

		//initialize circular outline path
        self.circleOutlinePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleBackgroundVisualEffectView.contentView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.contentView.center.y+self.cellWidth/2)
            radius:self.cellWidth/2
            startAngle:[self degreesToRadians:(-90)]
            endAngle:[self degreesToRadians:(270)]
            clockwise:TRUE];
        self.circleOutlineLayer = [[CAShapeLayer alloc] init];
        self.circleOutlineLayer.bounds = self.bounds;
        self.circleOutlineLayer.fillColor = [UIColor clearColor].CGColor;
		self.circleOutlineLayer.strokeStart = 0;
		self.circleOutlineLayer.strokeEnd = 0;
        self.circleOutlineLayer.path = [self.circleOutlinePath CGPath];
        self.circleOutlineLayer.lineWidth = self.cellWidth/10;
		self.circleOutlineLayer.masksToBounds = FALSE;
        [self.layer addSublayer:self.circleOutlineLayer];
		
		//rounds the corners of the outline layer 
		if(roundOutlineCorners){
			self.circleOutlineLayer.lineCap = kCALineCapRound;
		}

		//initialize device image and its constraints
		if(ios14){
			//COMMENT THIS BACK IN
			self.deviceGlyphView = [[UIImageView alloc] initWithImage:[connectedDevice batteryWidgetGlyph]];
			self.deviceGlyphView.image = [self.deviceGlyphView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		} else {
        	self.deviceGlyphView = [[UIImageView alloc] initWithImage:connectedDevice.glyph];
		}
		if ([batteryGlyphBackgroundMode isEqualToString:@"system"]) {
			[self.deviceGlyphView setTintColor:[UIColor labelColor]];
		} else if ([batteryGlyphBackgroundMode isEqualToString:@"dark"]) {
			[self.deviceGlyphView setTintColor:[UIColor lightTextColor]];
		} else if ([batteryGlyphBackgroundMode isEqualToString:@"light"]) {
			[self.deviceGlyphView setTintColor:[UIColor darkTextColor]];
		}

		CGFloat glyphAspectRatio = self.deviceGlyphView.frame.size.width/self.deviceGlyphView.frame.size.height;

		if(customDeviceGlyphSizeEnabled) {
			[self.deviceGlyphView.heightAnchor constraintEqualToConstant:customDeviceGlyphSize].active = TRUE;
			[self.deviceGlyphView.widthAnchor constraintEqualToConstant:customDeviceGlyphSize * glyphAspectRatio].active = TRUE;
		} else {
			[self.deviceGlyphView.heightAnchor constraintEqualToConstant:self.cellWidth * 0.6 ].active = TRUE;
			[self.deviceGlyphView.widthAnchor constraintEqualToConstant:self.cellWidth * 0.6 * glyphAspectRatio].active = TRUE;
		}
		if(ios14) {
			self.deviceGlyphView.transform = CGAffineTransformMake(1, 0, 0, 1, 0 ,0);
		}
		// self.deviceGlyphView.contentMode = UIViewContentModeScaleAspectFit;
		
		if(!hidePercentageLabel) {
			[self addArrangedSubview:self.devicePercentageLabel];
		}
		[self.circleBackgroundVisualEffectView.contentView addSubview:self.deviceGlyphView];
        self.deviceGlyphView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.deviceGlyphView.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        [self.deviceGlyphView.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor].active = TRUE;

		[self.circleBackgroundVisualEffectView setNeedsDisplay];
        self.deviceName = connectedDevice.name;
		self.deviceIdentifier = connectedDevice.identifier;
		self.deviceProductIdentifier = connectedDevice.productIdentifier;

        return self;
    }

    -(CGFloat)degreesToRadians:(CGFloat)arg1 {
        return arg1*(M_PI/180);
    }

    @synthesize cellWidth;

    -(CGFloat)getCellWidth {
        return cellWidth;
    }

    -(void)setCellWidth:(CGFloat)arg1 {
        cellWidth = arg1;
    }

    -(void)addPercentageSymbolToLabel {
		if(!hidePercent){
        	[self.devicePercentageString appendString:@"%"];
		}
    }

    -(long long)getDevicePercentage {
        return [self.device percentCharge];
    }

	-(void)updateDevicePercentage {
		self.devicePercentage = [self getDevicePercentage];
	}

	//updates a device's percentage and adjusts the label accordingly 
    -(void)updateDevicePercentageLabel {
		[self updateDevicePercentage];
        self.devicePercentageString = [NSMutableString stringWithFormat:@"%lld",self.devicePercentage];
		[self addPercentageSymbolToLabel];
        self.devicePercentageLabel.text = self.devicePercentageString;
    }

	-(void)removeFromSuperview {
		[super removeFromSuperview];
	}

	-(CGFloat)devicePercentageAsProgress {
		double progress = self.devicePercentage;
		return progress/100;
	}

	//true if the device is the iPhone/iPad, false otherwise
	-(BOOL)isDeviceInternal {
		return [self.device isInternal];
	}

	-(BOOL)isLowPowerModeOn {
		return [self.device isBatterySaverModeActive];
	}

	-(BOOL)isBatteryLow {
		return [self.device isLowBattery];
	}

	//updates the outline color depending on the device's charging/connected state
	-(void)updateOutlineColor {
		if([self isDeviceInternal] && [self isLowPowerModeOn] && ![self.device isCharging]){
			if([customLowPowerColorMode isEqualToString:@"custom"]) {
				self.circleOutlineLayer.strokeColor = colorFromHexString(customLowPowerColor).CGColor;
			} else if([customLowPowerColorMode isEqualToString:@"system"]) {
				self.circleOutlineLayer.strokeColor = [UIColor systemBlueColor].CGColor;
			} else {
				self.circleOutlineLayer.strokeColor = lowPowerModeColor.CGColor;
			}
		} else if([self isBatteryLow] && (![self.device isCharging])){
			if([customLowBatteryColorMode isEqualToString:@"custom"]) {
				self.circleOutlineLayer.strokeColor = colorFromHexString(customLowPowerColor).CGColor;
			} else if([customLowBatteryColorMode isEqualToString:@"system"]) {
				self.circleOutlineLayer.strokeColor = [UIColor systemBlueColor].CGColor;
			} else {
				self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
			}
		} else if([self.device isCharging] && pulsateChargingOutline){
			if([customChargingColorMode isEqualToString:@"custom"]) {
				self.circleOutlineLayer.strokeColor = colorFromHexString(customChargingColor).CGColor;
			} else if([customChargingColorMode isEqualToString:@"system"]) {
				self.circleOutlineLayer.strokeColor = [UIColor systemBlueColor].CGColor;
			} else {
				self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
			}
		} else {
			if(![self.device isConnected]){
				if([customDisconnectedDeviceColorMode isEqualToString:@"custom"]) {
					self.circleOutlineLayer.strokeColor = colorFromHexString(customDisconnectedDeviceColor).CGColor;
				} else if([customDisconnectedDeviceColorMode isEqualToString:@"system"]) {
					self.circleOutlineLayer.strokeColor = [UIColor systemBlueColor].CGColor;
				} else {
					self.circleOutlineLayer.strokeColor = [UIColor systemGrayColor].CGColor;
				}
			} else {
				if([customConnectedDeviceColorMode isEqualToString:@"custom"]) {
					self.circleOutlineLayer.strokeColor = colorFromHexString(customConnectedDeviceColor).CGColor;
				} else if([customConnectedDeviceColorMode isEqualToString:@"system"]) {
					self.circleOutlineLayer.strokeColor = [UIColor systemBlueColor].CGColor;
				} else {
					self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
				}
			}
		}
	}

	//starts the pulsating color animation sequence for charging devices
	-(void)pulsateOutline {
		if([self.device isCharging]){
			CAMediaTimingFunction *animationColorTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

			//initializes animations
			CABasicAnimation *normalToBright = [CABasicAnimation animationWithKeyPath:@"strokeColor"];	
			CABasicAnimation *brightToNormal = [CABasicAnimation animationWithKeyPath:@"strokeColor"];

			//assigns delegate to animations 
			PulsateColorAnimationDelegate *normalToBrightDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:brightToNormal];
			normalToBright.delegate = normalToBrightDelegate;
			PulsateColorAnimationDelegate *brightToNormalDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:normalToBright];
			brightToNormal.delegate = brightToNormalDelegate;

			if([customChargingColorMode isEqualToString:@"custom"]) {
				normalToBright.fromValue = id(colorFromHexString(customChargingColor).CGColor);
			} else if([customChargingColorMode isEqualToString:@"system"]) {
				normalToBright.fromValue = id([UIColor systemBlueColor].CGColor);
			} else {
				normalToBright.fromValue = id(normalBatteryColor.CGColor);
			}
			normalToBright.toValue = id(darkGrayColor.CGColor);
			normalToBright.duration = 2;
			normalToBright.timingFunction = animationColorTimingFunction;
			[normalToBright setFillMode:kCAFillModeForwards];
			[normalToBright setRemovedOnCompletion:FALSE];

			brightToNormal.fromValue = normalToBright.toValue;
			brightToNormal.toValue = normalToBright.fromValue; 
			brightToNormal.duration = 2;
			brightToNormal.timingFunction = animationColorTimingFunction;
			[brightToNormal setFillMode:kCAFillModeForwards];
			[brightToNormal setRemovedOnCompletion:FALSE];
			
			[self.circleOutlineLayer addAnimation:normalToBright forKey:kCATransition];
		}
	}

	//makes percentage label green if charging 
	-(void)updatePercentageColor {
		if([self.device isCharging]){
			if([customChargingColorMode isEqualToString:@"custom"]) {
				self.devicePercentageLabel.textColor = colorFromHexString(customChargingColor);
			} else if([customChargingColorMode isEqualToString:@"system"]) {
				self.devicePercentageLabel.textColor = [UIColor systemBlueColor];
			} else {
				self.devicePercentageLabel.textColor = normalBatteryColor;
			}
		}else {
			// self.devicePercentageLabel.textColor = [UIColor labelColor];
			if ([batteryTextColor isEqualToString:@"system"]) {
				self.devicePercentageLabel.textColor = [UIColor labelColor];
			} else if ([batteryTextColor isEqualToString:@"dark"]) {
				self.devicePercentageLabel.textColor = [UIColor blackColor];
			} else if ([batteryTextColor isEqualToString:@"light"]) {
				self.devicePercentageLabel.textColor = [UIColor whiteColor];
			} else if ([batteryTextColor isEqualToString:@"custom"]) {
				self.devicePercentageLabel.textColor = colorFromHexString(customBatteryTextColor);
			}
		}
	}

	//animates outline position along the bezier path
	-(void)newAnimateOuterLayerToCurrentPercentage{
		self.percentageAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		StrokeEndAnimationDelegate *delegate = [[StrokeEndAnimationDelegate alloc] initWithCell:self];
		self.percentageAnimation.delegate = delegate;
		self.percentageAnimation.fromValue = @(0.0);
		self.percentageAnimation.toValue = @([self devicePercentageAsProgress]);
		self.percentageAnimation.duration = 0.25;
		[self.percentageAnimation setFillMode:kCAFillModeForwards];
		[self.percentageAnimation setRemovedOnCompletion:TRUE];
		CAMediaTimingFunction *animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		self.percentageAnimation.timingFunction = animationTimingFunction;
		[self.circleOutlineLayer addAnimation:self.percentageAnimation forKey:kCATransition];
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						forKey:kCATransactionDisableActions];
		self.circleOutlineLayer.strokeEnd = [self devicePercentageAsProgress];
		[CATransaction commit];
	}

	//returns outline position to zero
	-(void)newAnimateOuterLayerToZero {
		self.circleOutlineLayer.strokeEnd = 0;
	}

@end

// @implementation VaonFavoriteContactsCell

// -(instancetype)initWithFrame:(CGRect)arg1 favoriteEntry:(CNFavoriteEntry *)favoriteEntry {
// 	self = [super initWithFrame:arg1];
// 	self.axis = UILayoutConstraintAxisVertical;
// 	self.alignment = UIStackViewAlignmentCenter;
// 	self.distribution = UIStackViewDistributionEqualSpacing;
// 	self.spacing = 10;
// 	self.clipsToBounds = TRUE;
// 	self.backgroundColor = [UIColor clearColor];
// 	self.translatesAutoresizingMaskIntoConstraints = FALSE;

// 	self.favoriteEntry = favoriteEntry;
// 	self.contact = favoriteEntry.contact;


// 	self.contactNameLabel = [[UILabel alloc] init];
// 	self.contactNameLabel.text = [self.favoriteEntry originalName];
// 	self.contactNameLabel.adjustsFontSizeToFitWidth = TRUE;
// 	self.contactNameLabel.frame = self.bounds;
// 	self.contactNameLabel.clipsToBounds = TRUE;

// 	[self addArrangedSubview:self.contactNameLabel];

// 	NSData *imageData = self.contact.imageData;

// 	UIImage *contactImage = [UIImage imageWithData:imageData];
// 	self.contactImageView = [[UIImageView alloc] initWithImage:contactImage];
// 	self.contactImageView.contentMode = UIViewContentModeScaleAspectFit;
// 	self.contactImageView.frame = self.bounds;
// 	self.contactImageView.clipsToBounds = TRUE;

// 	[self addArrangedSubview:self.contactImageView];

// 	return self;
// }

// @end

//initialize the battery view 
void initBatteryView(UIView *view){

	//initialize horizontal scroll view
	batteryScrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
	batteryScrollView.scrollsToTop = FALSE;
	batteryScrollView.directionalLockEnabled = TRUE;
	batteryScrollView.alwaysBounceVertical = FALSE;
	batteryScrollView.alwaysBounceHorizontal = FALSE;
	batteryScrollView.showsHorizontalScrollIndicator = TRUE;
	batteryScrollView.showsVerticalScrollIndicator = FALSE;

	//initialize horizontal stack view
	batteryHStackView = [[UIStackView alloc] initWithFrame:batteryScrollView.bounds];
	batteryHStackView.axis = UILayoutConstraintAxisHorizontal;
	batteryHStackView.alignment = UIStackViewAlignmentCenter;
	batteryHStackView.distribution = UIStackViewDistributionFill;
	if(horizontalSpacingBetweenDevicesEnabled) {
		batteryHStackView.spacing = horizontalSpacingBetweenDevices;
	} else {
		batteryHStackView.spacing = 30;
	}

	//gather bluetooth battery information
	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

	//adds to the view hierarchy
	[view addSubview:batteryScrollView];
	[batteryScrollView addSubview:batteryHStackView];


	if(!(currentSwitcherStyle == 2) && ios13){
		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *cell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			if(![device isInternal]){
				[batteryHStackView addArrangedSubview:cell]; 
			} else {
				if(!hideInternal){
					[batteryHStackView addArrangedSubview:cell]; 
				}
			}
		}
	}

	//scroll view constraints
	batteryScrollView.translatesAutoresizingMaskIntoConstraints = FALSE;
	[batteryScrollView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryScrollView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;
	[batteryScrollView.heightAnchor constraintEqualToAnchor:view.heightAnchor].active = TRUE;
	[batteryScrollView.widthAnchor constraintEqualToAnchor:view.widthAnchor].active = TRUE;

	//horizontal stack view constraints
	batteryHStackView.translatesAutoresizingMaskIntoConstraints = FALSE;
	[batteryHStackView.centerXAnchor constraintEqualToAnchor:batteryScrollView.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:batteryScrollView.centerYAnchor].active = TRUE;

	if((customWidthEnabled && batteryHStackView.bounds.size.width > customWidth) || batteryHStackView.bounds.size.width > dockWidth){
			batteryScrollView.scrollEnabled = TRUE;
				if(currentSwitcherStyle == 2){
					vaonGridView.userInteractionEnabled = TRUE;
				}else {
					// vaonView.userInteractionEnabled = TRUE;
				}
			}else{
				batteryScrollView.scrollEnabled = FALSE;

				if(currentSwitcherStyle == 2){
					vaonGridView.userInteractionEnabled = FALSE;
				}else {
					// vaonView.userInteractionEnabled = FALSE;
				}
		}
}

// void initFavoriteContactsView(UIView *view) {
// 	// favoriteContactsScrollView

// 	favoriteContactsHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
// 	favoriteContactsHStackView.axis = UILayoutConstraintAxisHorizontal;
// 	favoriteContactsHStackView.alignment = UIStackViewAlignmentCenter;
// 	favoriteContactsHStackView.distribution = UIStackViewDistributionEqualCentering;
// 	favoriteContactsHStackView.spacing = 80;
// 	favoriteContactsHStackView.clipsToBounds = TRUE;

// 	[view addSubview:favoriteContactsHStackView];

// 	NSArray *contactFavorites = [[%c(CNFavorites) sharedInstance] entries];

// 	for(CNFavoriteEntry *entry in contactFavorites){
// 		VaonFavoriteContactsCell *cell = [[VaonFavoriteContactsCell alloc] initWithFrame:favoriteContactsHStackView.bounds favoriteEntry:entry];
// 		[favoriteContactsHStackView addArrangedSubview:cell];
// 	}

// 	favoriteContactsHStackView.translatesAutoresizingMaskIntoConstraints = false;

// 	[favoriteContactsHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
// 	[favoriteContactsHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;
// }

//initialize the base background blur view 
void initBaseVaonView(UIView* view) {
	vaonViewBackgroundColor = [UIColor colorNamed:@"clearColor"];
	if ([backgroundMode isEqualToString:@"system"]) {
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
	} else if ([backgroundMode isEqualToString:@"dark"]) {
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
	} else if ([backgroundMode isEqualToString:@"light"]) {
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight];
	}
	titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
	view.clipsToBounds = TRUE;
	view.layer.cornerRadius = vaonViewCornerRadius;
	view.alpha = 0;
	view.backgroundColor = vaonViewBackgroundColor;
	// view.userInteractionEnabled = FALSE;
	
	// if(hideBackground) {
	// 	vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:nil];
	// } else {
	vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	// }
	vaonBlurView.frame = view.bounds;
	vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if(hideBackground) {
		vaonBlurView.effect = nil;
	}
	[view addSubview:vaonBlurView];
}

void updateScrollWidthAndTouchPassthrough() {
	NSLog(@"Vaon updateScrollWidthAndTouchPassthrough %f", batteryHStackView.bounds.size.width);
	NSLog(@"Vaon updateScrollWidthAndTouchPassthrough %f", customWidth);
	if((customWidthEnabled && batteryHStackView.bounds.size.width > customWidth) || batteryHStackView.bounds.size.width > dockWidth){
		batteryScrollView.scrollEnabled = TRUE;
			if(currentSwitcherStyle == 2){
				vaonGridView.userInteractionEnabled = TRUE;
			}else {
				vaonView.userInteractionEnabled = TRUE;
				batteryScrollView.userInteractionEnabled = TRUE;
				batteryHStackView.userInteractionEnabled = TRUE;
				if(switcherContentView) {
					switcherContentView.userInteractionEnabled = TRUE;	
				}
			}
		}else{
			batteryScrollView.scrollEnabled = FALSE;

			if(currentSwitcherStyle == 2){
				vaonGridView.userInteractionEnabled = FALSE;
			}else {
				vaonView.userInteractionEnabled = FALSE;
				batteryScrollView.userInteractionEnabled = FALSE;
				batteryHStackView.userInteractionEnabled = FALSE;
				if(switcherContentView) {
					switcherContentView.userInteractionEnabled = FALSE;	
				}
			}
	}
	NSLog(@"Vaon updateScrollWidthAndTouchPassthrough %i", vaonView.userInteractionEnabled);

}

//updates battery information 
void updateBattery(){
	//access main loop
	dispatch_async(dispatch_get_main_queue(), ^{

		NSLog(@"Vaon iOS 13 Updating Battery Info");
		[batteryScrollView setContentSize:CGSizeMake(batteryHStackView.bounds.size.width, batteryHStackView.bounds.size.height)];
		if(batteryHStackView.bounds.size.width > dockWidth){
			batteryScrollView.contentInset = UIEdgeInsetsMake(0,batteryHStackView.bounds.size.width/4,0,0);
		}else{
			batteryScrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
		}

		// CGFloat mainScreenWidth = [[UIScreen mainScreen] bounds].size.width;

		// if( batteryScrollView.contentSize.width > mainScreenWidth){
		// 	if(customSwitcherStyle == 2){
		// 		vaonGridView.userInteractionEnabled = FALSE;
		// 	} else {
				// vaonView.userInteractionEnabled = FALSE;
		// 	}
		// }

		//update list of bluetooth devices
		connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		// connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] _sortedDevices];
		NSMutableArray *subviewsToBeAdded = [[NSMutableArray alloc] init];

		//loops through and finds new devices to add 
		for(BCBatteryDevice *device in connectedBluetoothDevices){

			VaonDeviceBatteryCell *newCell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			BOOL duplicate = FALSE;


			for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
				if([subview.deviceName isEqualToString:newCell.deviceName] || [subview.deviceIdentifier isEqualToString:newCell.deviceIdentifier]){
					duplicate = TRUE;
				}
			}


			//checks if devices are not already on the horizontal stack and the list of device names
			if(![batteryHStackView.subviews containsObject:newCell] && ![deviceNames containsObject:newCell.deviceName] && !duplicate){
				//add all devices that are not the iPhone/iPad
				if(![device isInternal]){
					[subviewsToBeAdded addObject:newCell];			
					[deviceIdentifiers addObject:[newCell.device identifier]];
					// [deviceNames addObject:[newCell.device name]];			
				} else{
					//displays the iphone if hideInternal is off
					if(!hideInternal){
						[subviewsToBeAdded addObject:newCell];
						[deviceIdentifiers addObject:[newCell.device identifier]];
						// [deviceNames addObject:[newCell.device name]];			
					}							
				}
			}
		}

		//animate and add subviews to the hstack
		for(VaonDeviceBatteryCell *subview in subviewsToBeAdded){

			[batteryHStackView addArrangedSubview:subview];
			subview.alpha = 0;
			//fade in new devices
			[UIView animateWithDuration:0.3 animations:^ {
				subview.alpha = 1;

			}
			completion:^(BOOL finished) {
				//when finished animate the outer layer to its percentage position
				[subview newAnimateOuterLayerToCurrentPercentage];
				[subviewsToBeAdded removeObject:subview];
			}];	
		}

		//counts how many times a device exists and stores all the position in the array
		//then remove all the indexes except the first one
		
		//update device view properties
		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){

			//checks if the device is not connected anymore 
			if((![connectedBluetoothDevices containsObject:subview.device] && ![subview.device isConnected]) || subview.device == nil ){
				//if keep is turned on, keep the device and just update its properties
				if(keepDisconnectedDevices){
					if(subview.device == nil){
						for(BCBatteryDevice *device in connectedBluetoothDevices){
							if([subview.deviceName isEqual:[device name]]){
								subview.device = device;
								[subview updateOutlineColor];
								[subview updatePercentageColor];
								// subview.deviceGlyphView = [[UIImageView alloc] initWithImage:subview.device.glyph];
								// if(ios14){
								// 	subview.deviceGlyphView = [[UIImageView alloc] initWithImage:[subview.device batteryWidgetGlyph]];
								// } else {
								// 	subview.deviceGlyphView = [[UIImageView alloc] initWithImage:subview.device.glyph];
								// }
							}
						}
					}
				}else{
					//remove subviews that aren't connected if keepDisconnectedDevices is turned off
					subview.alpha = 1;
					//fade out
					[UIView animateWithDuration:0.3 animations:^ {
						subview.alpha = 0;
					}
					completion:^(BOOL finished) {
						[subview removeFromSuperview];
						[deviceIdentifiers removeObject:[subview.device identifier]];
						[deviceNames removeObject:subview.deviceName];			
					}];	
				}
			}

			//updates outline color and percentage values 
			if(keepDisconnectedDevices){	
				[subview updateOutlineColor];
				[subview updatePercentageColor];

				//if the device is still connected update its battery data
				if([subview.device isConnected]){
					[subview updateDevicePercentage];
					[subview updateDevicePercentageLabel];
				}
			} else {
				[subview updateDevicePercentageLabel];
				[subview updateOutlineColor];
				[subview updatePercentageColor];
				[subview updateDevicePercentage];
			}
		}

	}); 

	// if(batteryHStackView.bounds.size.width > dockWidth){
	// 		batteryScrollView.scrollEnabled = TRUE;
	// 			if(currentSwitcherStyle == 2){
	// 				vaonGridView.userInteractionEnabled = TRUE;
	// 			}else {
	// 				vaonView.userInteractionEnabled = TRUE;
	// 			}
	// 		}else{
	// 			batteryScrollView.scrollEnabled = FALSE;

	// 			if(currentSwitcherStyle == 2){
	// 				vaonGridView.userInteractionEnabled = FALSE;
	// 			}else {
	// 				NSLog(@"Vaon print passthrough on");
	// 				vaonView.userInteractionEnabled = FALSE;
	// 			}
	// 	}
}


void iOS14UpdateBattery(){
	NSLog(@"Vaon iOS 14 Battery Updates");

		// dispatch_async(dispatch_get_main_queue(), ^{

		[batteryScrollView setContentSize:CGSizeMake(batteryHStackView.bounds.size.width, batteryHStackView.bounds.size.height)];

		if(batteryHStackView.bounds.size.width > dockWidth){
			batteryScrollView.contentInset = UIEdgeInsetsMake(0,batteryHStackView.bounds.size.width/4,0,0);
		}else{
			batteryScrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
		}


		//update list of bluetooth devices
		connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		// connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] _sortedDevices];
		NSMutableArray *subviewsToBeAdded = [[NSMutableArray alloc] init];

		//loops through and finds new devices to add 
		for(BCBatteryDevice *device in connectedBluetoothDevices){

			// if(device != nil || [device.name isEqual:@"(null)"] || [device isEqual:@"(null)"]){
			if(device || device != nil){
				BOOL duplicate = FALSE;
				VaonDeviceBatteryCell *newCell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
				
				// NSLog(@"Vaon contains %i", ![deviceNames containsObject:newCell.device.name]);

				//checks if devices are not already on the horizontal stack and the list of device names
				for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
					NSLog(@"Vaon name %@ | %@ | %@", subview.deviceName, subview.deviceIdentifier, newCell.deviceIdentifier);
					[deviceNames addObject:subview.deviceName];
					if([subview.deviceName isEqualToString:newCell.deviceName] || [subview.deviceIdentifier isEqualToString:newCell.deviceIdentifier]){
						duplicate = TRUE;
					}
				}
				if(![batteryHStackView.subviews containsObject:newCell] && ![deviceNames containsObject:newCell.deviceName] && !duplicate){
					//add all devices that are not the iPhone/iPad
					if(![device isInternal]){
						[subviewsToBeAdded addObject:newCell];
						[deviceIdentifiers addObject:[newCell.device identifier]];
						// [deviceNames addObject:[newCell.device name]];
					} else{
						//displays the iphone if hideInternal is off
						if(!hideInternal){
							[subviewsToBeAdded addObject:newCell];
							[deviceIdentifiers addObject:[newCell.device identifier]];
							// [deviceNames addObject:[newCell.device name]];
						}
					}
				}
			}
		}



		//animate and add subviews to the hstack
		for(VaonDeviceBatteryCell *subview in subviewsToBeAdded){

			if(subview.device || subview.device != nil){
				[batteryHStackView addArrangedSubview:subview];
				subview.alpha = 0;
				//fade in new devices
				// subview.frame = CGRectMake(subview.frame.origin.x, -200 , subview.frame.size.width, subview.frame.size.height);
				[UIView animateWithDuration:0.3 animations:^ {
					subview.alpha = 1;
					// subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y, subview.frame.size.width, subview.frame.size.height);

				}
				completion:^(BOOL finished) {
					//when finished animate the outer layer to its percentage position
					if(finished){
						[subview newAnimateOuterLayerToCurrentPercentage];
						[subviewsToBeAdded removeObject:subview];
						updateScrollWidthAndTouchPassthrough();
					}
				}];	
			}
		}



		//update device view properties
		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){

			if(!subview.device) {
				for(BCBatteryDevice *device in connectedBluetoothDevices) {
					if([device.name isEqual:subview.deviceName]) {
						subview.device = device;

						// Didn't fix glyph not displaying correct device issue
						// subview.deviceGlyphView = [[UIImageView alloc] initWithImage:[device batteryWidgetGlyph]];
					}
				}
			}

			// for(NSString *name in deviceNames){
			// 	if ([subview.device.name isEqual:name]){
			// 		[UIView animateWithDuration:0.3 animations:^ {
			// 			subview.alpha = 0;
			// 		}
			// 		completion:^(BOOL finished) {
			// 			[subview removeFromSuperview];
			// 			[deviceIdentifiers removeObject:[subview.device identifier]];
			// 			NSUInteger index = [deviceNames indexOfObject:name];

			// 			if(index > -1 && index < [deviceNames count]){
			// 				[deviceNames removeObjectAtIndex:index];			
			// 			}
			// 		}];	
			// 	}
			// }


			// if(subview.device || subview.device != nil){
			//checks if the device is not connected anymore 
			if((![connectedBluetoothDevices containsObject:subview.device] && ![subview.device isConnected])){
				//if keep is turned on, keep the device and just update its properties
				if(keepDisconnectedDevices){
					if(subview.device == nil){
						for(BCBatteryDevice *device in connectedBluetoothDevices){
							if([subview.deviceName isEqual:[device name]]){
								subview.device = device;
								[subview updateOutlineColor];
								[subview updatePercentageColor];
							}
						}
					}
				} else{
					//remove subviews that aren't connected if keepDisconnectedDevices is turned off
					// subview.alpha = 1;
					//fade out
					[UIView animateWithDuration:0.3 animations:^ {
						subview.alpha = 0;
					}
					completion:^(BOOL finished) {
						[subview removeFromSuperview];
						[deviceIdentifiers removeObject:[subview.device identifier]];
						// [deviceNames removeObject:subview.deviceName];			
					}];	
				}
			}

			// NSLog(@"Vaon Device Name: %@ Percentage: %lld", subview.device, subview.device.percentCharge);

			//updates outline color and percentage values 
			if(keepDisconnectedDevices){	
				[subview updateOutlineColor];
				[subview updatePercentageColor];

				//if the device is still connected update its battery data
				if([subview.device isConnected]){
					[subview updateDevicePercentage];
					[subview updateDevicePercentageLabel];
				}
			} else {
				[subview updateDevicePercentageLabel];
				[subview updateOutlineColor];
				[subview updatePercentageColor];
				[subview updateDevicePercentage];
			}
			// }
		}

	// }); 
}




//fade in the base Vaon view
void fadeViewIn(UIView *view, CGFloat duration){
	// stockHidden = TRUE;

	updateScrollWidthAndTouchPassthrough();

	CGRect mainScreen = [[UIScreen mainScreen] bounds];

	if(firstSlideIn && !enableFlyInOut){
		if(customVerticalOffsetEnabled){
			view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height + customVerticalOffset - view.frame.size.height, view.frame.size.width, view.frame.size.height);
		} else {
			view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height - 25 - view.frame.size.height, view.frame.size.width, view.frame.size.height);
		}
	}

	[UIView animateWithDuration:duration animations:^ {
		if(firstSlideIn && enableFlyInOut){
			if(customVerticalOffsetEnabled){
				view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height + customVerticalOffset - view.frame.size.height, view.frame.size.width, view.frame.size.height);
			} else {
				view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height - 25 - view.frame.size.height, view.frame.size.width, view.frame.size.height);
			}
		}

		view.alpha = 1;

	} completion:^(BOOL finished) {
		if(view.alpha==1){
			if([selectedModule isEqual:@"battery"]){
				if(finished){
					for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
						if(firstSlideIn) {
							[subview newAnimateOuterLayerToCurrentPercentage];
						}
						stockHidden = FALSE;
					}
					if(ios13){
						updateBattery();
					}
					if(ios14){
						iOS14UpdateBattery();
					}
				}
			}
		}
		firstSlideIn = true;	
		// if(batteryHStackView.bounds.size.width > customWidth){
		// 	batteryScrollView.scrollEnabled = TRUE;
		// 		if(currentSwitcherStyle == 2){
		// 			vaonGridView.userInteractionEnabled = TRUE;
		// 		}else {
		// 			vaonView.userInteractionEnabled = TRUE;
		// 			batteryScrollView.userInteractionEnabled = TRUE;
		// 			if(switcherContentView) {
		// 				switcherContentView.userInteractionEnabled = TRUE;	
		// 			}
		// 		}
		// 	}else{
		// 		batteryScrollView.scrollEnabled = FALSE;

		// 		if(currentSwitcherStyle == 2){
		// 			vaonGridView.userInteractionEnabled = FALSE;
		// 		}else {
		// 			vaonView.userInteractionEnabled = FALSE;
		// 			batteryScrollView.userInteractionEnabled = FALSE;
		// 			batteryHStackView.userInteractionEnabled = FALSE;
		// 			if(switcherContentView) {
		// 				switcherContentView.userInteractionEnabled = FALSE;	
		// 			}
		// 		}
		// }

	}];	

}

//fade the base Vaon view out
void fadeViewOut(UIView *view, CGFloat duration){
	NSLog(@"Vaon Fade Out %i", stockHidden);



	//animate all the outlines back to their original position
	for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
		[subview newAnimateOuterLayerToZero];
	}	
	// [view.centerYAnchor constraintEqualToAnchor:view.bottomAnchor constant:200].active = TRUE;
	CGRect mainScreen = [[UIScreen mainScreen] bounds];

	if(!enableFlyInOut) {
		view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height + 200, view.frame.size.width, view.frame.size.height);
	}

	[UIView animateWithDuration:duration animations:^ {
		// [view layoutIfNeeded];
		if(enableFlyInOut) {
			view.frame = CGRectMake(view.frame.origin.x, mainScreen.size.height + 200, view.frame.size.width, view.frame.size.height);
		}

		view.alpha = 0;
		
	} completion:^(BOOL finished) {
			stockHidden = TRUE;
			updateScrollWidthAndTouchPassthrough();
	}];	
}

//update battery information and displayed data
%group BatteryModeUpdates

//have an if statement in each method to only trigger if the vaonView is not hidden

%hook BCBatteryDevice

	-(void)setCharging: (BOOL)arg1 {
		%orig;
		if(ios13){
			updateBattery();
		}
		// [self updateScrollWidthAndTouchPassthrough];
		updateScrollWidthAndTouchPassthrough();

	}
	-(void)setBatterSaveModeActive:(BOOL)arg1 {
		if(ios13){
			updateBattery();
		}
		// [self updateScrollWidthAndTouchPassthrough];
		updateScrollWidthAndTouchPassthrough();

		%orig;
	}
	-(void)setPercentCharge:(long long)arg1 {
		if(arg1!=0){
			if(ios13){
				updateBattery();
			}		
		}
		%orig;
	}
	-(void)dealloc {
		%orig;
		if(ios13){
			updateBattery();
		}
	}

// 	%new
// 	-(void)updateScrollWidthAndTouchPassthrough {
// 		if(batteryHStackView.bounds.size.width > customWidth){
// 			batteryScrollView.scrollEnabled = TRUE;
// 				if(currentSwitcherStyle == 2){
// 					vaonGridView.userInteractionEnabled = TRUE;
// 				}else {
// 					vaonView.userInteractionEnabled = TRUE;
// 					if(switcherContentView) {
// 						switcherContentView.userInteractionEnabled = TRUE;	
// 					}
// 				}
// 			}else{
// 				batteryScrollView.scrollEnabled = FALSE;

// 				if(currentSwitcherStyle == 2){
// 					vaonGridView.userInteractionEnabled = FALSE;
// 				}else {
// 					vaonView.userInteractionEnabled = FALSE;
// 					if(switcherContentView) {
// 						switcherContentView.userInteractionEnabled = FALSE;	
// 					}
// 				}
// 		}
// 		NSLog(@"Vaon updateScrollWidthAndTouchPassthrough %i", vaonView.userInteractionEnabled);

// 	}
 
 %end

%end



%group iOS13BatteryModeUpdates

 %hook BCBatteryDeviceController
 	//both methods are only supported in iOS 13

	-(void)addDeviceChangeHandler:(id)arg1 withIdentifier:(id)arg2 {
		%orig;
		updateBattery();
	}

	-(void)removeDeviceChangeHandlerWithIdentifier:(id)arg1 {
		%orig;
		updateBattery();
	}

 %end

%end

%hook SBSwitcherAppSuggestionContentView

	//creates vaonview for normal/non-grid app switcher 
	-(void)didMoveToWindow {
		%orig;
		switcherContentView = self;
		if(![selectedModule isEqual:@"none"]){
			CGFloat mainScreen = [[UIScreen mainScreen] bounds].size.height;
			if(!vaonViewIsInitialized && !(currentSwitcherStyle==2)){

				vaonView = [[UIView alloc] init];


				initBaseVaonView(vaonView);

				if([selectedModule isEqual:@"battery"]){	
					initBatteryView(vaonView);
				}else if([selectedModule isEqual:@"favoriteContacts"]){
					// initFavoriteContactsView(vaonView);
				}


				[self addSubview:vaonView];


				CGFloat vaonViewHeight = vaonView.frame.size.height;

				//vaon view constraints and placement
				vaonView.translatesAutoresizingMaskIntoConstraints = false;
				if(customVerticalOffsetEnabled){
					[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:vaonViewHeight+customVerticalOffset].active = TRUE;
				} else{
					[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-25].active = TRUE;
					// [vaonGridView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-80].active = TRUE;
				}
				if(customHorizontalOffsetEnabled) {
					[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:customHorizontalOffset].active = TRUE;
				} else {
					[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
				}
				if(customWidthEnabled){
					[vaonView.widthAnchor constraintEqualToConstant:customWidth].active = TRUE;
				} else{
					[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
				}
				if(customHeightEnabled){
					[vaonView.heightAnchor constraintEqualToConstant:customHeight].active = TRUE;
				} else{
					[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = TRUE;
				}

				vaonViewIsInitialized = TRUE;
			}	
		}
		
		if(mainAppSwitcherVC.sbActiveInterfaceOrientation==1){
			SBApplication *frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
			NSString *currentAppDisplayID = [frontApp bundleIdentifier];



			updateScrollWidthAndTouchPassthrough();

			if(self.window != nil){
				// opening the app switcher from the home screen
				if(currentAppDisplayID==nil && stockHidden){
					if(enableDelay) {
							delayedFadeInTimer = [NSTimer scheduledTimerWithTimeInterval:fadeInDelay target:self selector:@selector(delayedFadeViewIn) userInfo:nil repeats:NO];
					} else {
						fadeViewIn(vaonView, 0.4);
					}
				} else {
					if(stockHidden){	
						//TODO: look into this
						// vaonView.userInteractionEnabled = FALSE;
						// batteryHStackView.userInteractionEnabled = FALSE;
						// batteryScrollView.userInteractionEnabled = FALSE;
						// if(switcherContentView) {
						// 	switcherContentView.userInteractionEnabled = FALSE;	
						// }

						if(enableDelay) {
							delayedFadeInTimer = [NSTimer scheduledTimerWithTimeInterval:fadeInDelay target:self selector:@selector(delayedFadeViewIn) userInfo:nil repeats:NO];
						} else {
							fadeViewIn(vaonView, 0.4);
						}
					}
				}
			} 
		}

	}

	%new 
	-(void)delayedFadeViewIn {
		fadeViewIn(vaonView, 0.4);
		[delayedFadeInTimer invalidate];
		delayedFadeInTimer = nil;	
	}

%end


//grid view hook
%hook SBMainSwitcherViewController

	-(void)viewDidLoad {
		%orig;
		mainAppSwitcherVC = self;
		dockWidth = mainAppSwitcherVC.view.frame.size.width*0.943;	

		if(![selectedModule isEqual:@"none"]){	

			//initializes vaon for grid mode 
			if(currentSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
				if(!vaonViewIsInitialized){
					vaonGridView = [[UIView alloc] init];

					initBaseVaonView(vaonGridView);

					if([selectedModule isEqual:@"battery"]){	
						initBatteryView(vaonGridView);
					}else if([selectedModule isEqual:@"favoriteContacts"]){
						// initFavoriteContactsView(vaonGridView);
					}
					
					[self.view addSubview:vaonGridView];

					CGFloat vaonViewHeight = vaonView.frame.size.height;


					//grid mode constraints and vaon view placement
					vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
					if(customVerticalOffsetEnabled){
						[vaonGridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:vaonViewHeight+customVerticalOffset].active = TRUE;
					} else{
						[vaonGridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-25].active = TRUE;
					}
					if(customHorizontalOffsetEnabled) {
						[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:customHorizontalOffset].active = TRUE;
					} else {
						[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = TRUE;
					}
					if(customWidthEnabled){
						[vaonGridView.widthAnchor constraintEqualToConstant:customWidth].active = TRUE;
					} else{
						[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
					}
					if(customHeightEnabled){
						[vaonGridView.heightAnchor constraintEqualToConstant:customHeight].active = TRUE;
					} else{
						[vaonGridView.heightAnchor constraintEqualToConstant:113].active = TRUE;
					}
					vaonViewIsInitialized = TRUE;
				}
			}
		}
	}

	

	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {
		%orig;
		NSLog(@"Vaon test isMainSwitcherVisible %i", enteredApp);
		if(delayedFadeInTimer) {
			[delayedFadeInTimer invalidate];
			delayedFadeInTimer = nil;
			if(vaonView) {
				// vaonView.alpha = 0;
				fadeViewOut(vaonView, 0.2);
			}
		}

		if(enteredApp) {
			if(vaonView) {
				// vaonView.alpha = 0;
				fadeViewOut(vaonView, 0.2);
			}
		}

		if(![selectedModule isEqual:@"none"] && customSwitcherStyle != 2){
			if(!stockHidden){
				fadeViewOut(vaonView, 0.5);
			}
		} 
		// else if(![selectedModule isEqual:@"none"]){
		// 	if(delayedFadeInTimer) {
		// 		if(vaonGridView.alpha != 1) {
		// 			NSLog(@"Vaon entered app %@", delayedFadeInTimer);
		// 			[delayedFadeInTimer invalidate];
		// 			delayedFadeInTimer = nil;
		// 			// SBApplication *frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		// 			// NSString *currentAppDisplayID = [frontApp bundleIdentifier];
		// 			// if(currentAppDisplayID) {
		// 				if(customSwitcherStyle != 2) {
		// 					vaonView.alpha = 0;
		// 				} else {
		// 					vaonGridView.alpha = 0;
		// 				}
		// 			// }
		// 			NSLog(@"Vaon entered app %@", delayedFadeInTimer);
		// 		} else {
		// 			if(customSwitcherStyle != 2) {
		// 				fadeViewIn(vaonView, 0.4);
		// 			}
		// 		}
		// 	}
		// }

	}


	-(BOOL)isMainSwitcherVisible {
		enteredApp = %orig;
		return %orig;
	}



	//fade in and out for vaon in grid mode
	-(void)_updateDisplayLayoutElementForLayoutState: (id)arg1 {
		%orig;
		if(![selectedModule isEqual:@"none"]){
			appSwitcherOpen = [self isAnySwitcherVisible];
			if(currentSwitcherStyle == 2 && self.sbActiveInterfaceOrientation == 1){
				if(!appSwitcherOpen){
					fadeViewOut(vaonGridView, 0.3);
				}else{
					if(!(vaonGridView.alpha==1)){
						NSLog(@"Vaon Grid Timer %i", enableDelay);
						if(enableDelay) {
							delayedFadeInTimer = [NSTimer scheduledTimerWithTimeInterval:fadeInDelay target:self selector:@selector(delayedGridFadeViewIn) userInfo:nil repeats:NO];
						} else {
							fadeViewIn(vaonGridView, 0.4);
						}
					}
				}
			}

			if(currentSwitcherStyle != 2 && self.sbActiveInterfaceOrientation == 1){
				if(!stockHidden && !appSwitcherOpen){
					fadeViewOut(vaonView, 0.3);
				}
			}
		}
	}

	%new 
	-(void)delayedGridFadeViewIn{
		fadeViewIn(vaonGridView, 0.4);
		[delayedFadeInTimer invalidate];
		delayedFadeInTimer = nil;
	}
%end


%hook SBAppSwitcherSettings

	//Enable and customize grid mode 
	-(void)setSwitcherStyle: (long long)arg1 {
		if(customSwitcherStyle==2){
			%orig(2);
		}else {
			%orig;
		}
		currentSwitcherStyle = self.switcherStyle;
	}

	- (void) setGridSwitcherPageScale: (double)arg1 {
		if(customGridSwitcherAppSizeEnabled) {
			%orig(customGridSwitcherAppSize);
		} else {
			%orig(0.25);
		}
	}

	-(void)setGridSwitcherVerticalNaturalSpacingPortrait: (double)arg1 {
		if(customGridSwitcherSpacingEnabled) {
			%orig(customGridSwitcherSpacing);

		} else {
			%orig(40);
		}
	}
%end



%hook SBSwitcherAppSuggestionBannerView

	//hide the iOS suggestion banner that interferes with Vaon
	-(void)didMoveToWindow {
		%orig;
		if(hideSuggestionBanner){
			self.hidden = TRUE;
		}
	}
%end


%hook SBFluidSwitcherItemContainer

	//hide app titles 
	- (void)setTitleOpacity:(double)arg1 {
		if(hideAppTitles){
			%orig(0);
		}else {
			%orig;
		}
	}

	// -(id)initWithFrame:(CGRect)arg1 {
	// 	return %orig(CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height));
	// }
	// -(void)setContentView:(UIView*)arg1 {
	// 	UIView *view = arg1;
	// 	view.frame = CGRectMake(arg1.frame.origin.x, arg1.frame.origin.y-200, arg1.frame.size.width, arg1.frame.size.height);
	// 	%orig(view);
	// }
	
	// -(CGRect)_frameForPageView {
	// 	return CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height);
	// 	// return CGRectMake(self._pageView.frame.origin.x, pageView.frame.origin.y-200, pageView.frame.size.width, pageView.frame.size.height);
	// }
	// -(CGRect)_frameForScrollView {
	// 	return CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height);

	// }

%end


%hook SBFluidSwitcherIconImageContainerView 

	-(void)didMoveToWindow {
		%orig;
		if(hideAppIcons) {
			self.alpha = 0;
		}

	}

%end

//displays vaon when no apps are open
%hook SBFluidSwitcherAnimationSettings
	-(void)setEmptySwitcherDismissDelay:(double)arg1 {
		if(displayWithNoApps) {
			%orig(2);
		} else {
			%orig(arg1);
		}
	}
%end



// %hook SBAppSwitcherPageView
// 	// -(void)setFrame:(CGRect)frame {
// 	// 	%orig(CGRectMake(frame.origin.x, frame.origin.y-200, frame.size.width, frame.size.height));

// 	// }
// 	-(void)didMoveToWindow {
// 		%orig;
// 		// self.alpha = 0.5;
// 		// self.hidden = TRUE;
// 	}
// %end

// %hook SBGridSwitcherViewController

// 	-(void)viewDidLoad {
// 		%orig;
// 		self.viewIfLoaded.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-200, self.view.frame.size.width, self.view.frame.size.height);
// 	}
// %end


// %hook SBOrientationTransformWrapperView
// -(void)setFrame:(CGRect)arg1 {
// 		%orig(CGRectMake(arg1.origin.x, arg1.origin.y-500, arg1.size.width, arg1.size.height));
// 	}
// 	// -(void)setFrameOrigin:(CGPoint)arg1{
// 	// 	%orig(CGPointMake(arg1.x, arg1.y-200));
// 	// }
// 	// -(void)_constantsForVerticalAutoresizingConstraints:(double*)arg1 :(double*)arg2
// %end


void updateSettings(){
	[prefs registerDefaults:@{
		@"isEnabled": @TRUE,
		@"switcherMode": @"grid",
		@"moduleSelection": @"battery",
		@"hideBackground": @FALSE,
		@"hideAppTitles": @FALSE,
		@"hideAppIcons": @FALSE,
		@"hideSuggestionBanner": @TRUE,
		@"displayWithNoApps": @TRUE,
		@"backgroundMode": @"system",
		@"enableFlyInOut": @TRUE,
		@"enableDelay": @FALSE,
		@"fadeInDelay": @0.5,
		@"customHeightEnabled": @FALSE,
		@"customHeight": @113,
		@"customWidthEnabled": @FALSE,
		@"customWidth": @400,
		@"customVerticalOffsetEnabled": @FALSE,
		@"customVerticalOffset": @-80,
		@"customHorizontalOffsetEnabled": @FALSE,
		@"customHorizontalOffset": @0,
		@"hideInternal": @FALSE,
		@"hidePercentageLabel": @FALSE,
		@"hidePercent": @FALSE,
		@"enableBoldPercentage": @TRUE,
		@"roundOutlineCorners": @TRUE,
		@"pulsateChargingOutline": @TRUE,
		@"keepDisconnectedDevices": @TRUE,
		@"batteryTextColor": @"system",
		@"customBatteryTextColor": @"#FFFFFF",
		@"batteryGlyphBackgroundMode": @"system",
		@"customDeviceGlyphSizeEnabled": @FALSE,
		@"customDeviceGlyphSize": @30,
		@"customBatteryCellSizeEnabled": @FALSE,
		@"customBatteryCellSize": @50,
		@"customPercentageFontSizeEnabled": @FALSE,
		@"customPercentageFontSize": @12,
		@"paddingBetweenGlyphAndLabelEnabled": @FALSE,
		@"paddingBetweenGlyphAndLabel": @0,
		@"horizontalSpacingBetweenDevicesEnabled": @FALSE,
		@"horizontalSpacingBetweenDevices": @30,
		@"customGridSwitcherAppSizeEnabled": @FALSE,
		@"customGridSwitcherAppSize": @0.25,
		@"customGridSwitcherSpacingEnabled": @FALSE,
		@"customGridSwitcherSpacing": @40,
		@"customConnectedDeviceColorMode": @"default",
		@"customConnectedDeviceColor": @"#33b5e5",
		@"customDisconnectedDeviceColorMode": @"default",
		@"customDisconnectedDeviceColor": @"#33b5e5",
		@"customLowPowerColorMode": @"default",
		@"customLowPowerColor": @"#33b5e5",
		@"customLowBatteryColorMode": @"default",
		@"customLowBatteryColor": @"#33b5e5",
		@"customChargingColorMode": @"default",
		@"customChargingColor": @"#33b5e5"
	}];

	isEnabled = [[prefs objectForKey:@"isEnabled"] boolValue];
	switcherMode = [prefs objectForKey:@"switcherMode"];
	selectedModule = [prefs objectForKey:@"moduleSelection"];
	hideBackground = [[prefs objectForKey:@"hideBackground"] boolValue];
	hideAppTitles = [[prefs objectForKey:@"hideAppTitles"] boolValue];
	hideAppIcons = [[prefs objectForKey:@"hideAppIcons"] boolValue];
	hideSuggestionBanner = [[prefs objectForKey:@"hideSuggestionBanner"] boolValue];
	displayWithNoApps = [[prefs objectForKey:@"displayWithNoApps"] boolValue];
	backgroundMode = [prefs objectForKey:@"backgroundMode"];
	enableFlyInOut = [[prefs objectForKey:@"enableFlyInOut"] boolValue];
	enableDelay = [[prefs objectForKey:@"enableDelay"] boolValue];
	fadeInDelay = [[prefs objectForKey:@"fadeInDelay"] floatValue];
	customHeightEnabled = [[prefs objectForKey:@"customHeightEnabled"] boolValue];
	customHeight = [[prefs objectForKey:@"customHeight"] floatValue];
	customWidthEnabled = [[prefs objectForKey:@"customWidthEnabled"] boolValue];
	customWidth = [[prefs objectForKey:@"customWidth"] floatValue];
	customVerticalOffsetEnabled = [[prefs objectForKey:@"customVerticalOffsetEnabled"] boolValue];
	customVerticalOffset = [[prefs objectForKey:@"customVerticalOffset"] floatValue];
	customHorizontalOffsetEnabled = [[prefs objectForKey:@"customHorizontalOffsetEnabled"] boolValue];
	customHorizontalOffset = [[prefs objectForKey:@"customHorizontalOffset"] floatValue];
	hideInternal = [[prefs objectForKey:@"hideInternal"] boolValue];
	hidePercentageLabel = [[prefs objectForKey:@"hidePercentageLabel"] boolValue];
	hidePercent = [[prefs objectForKey:@"hidePercent"] boolValue];
	enableBoldPercentage = [[prefs objectForKey:@"enableBoldPercentage"] boolValue];
	roundOutlineCorners = [[prefs objectForKey:@"roundOutlineCorners"] boolValue];
	pulsateChargingOutline = [[prefs objectForKey:@"pulsateChargingOutline"] boolValue];
	keepDisconnectedDevices = [[prefs objectForKey:@"keepDisconnectedDevices"] boolValue];
	batteryTextColor = [prefs objectForKey:@"batteryTextColor"];
	customBatteryTextColor = [prefs objectForKey:@"customBatteryTextColor"];
	batteryGlyphBackgroundMode = [prefs objectForKey:@"batteryGlyphBackgroundMode"];
	customDeviceGlyphSizeEnabled = [[prefs objectForKey:@"customDeviceGlyphSizeEnabled"] boolValue];
	customDeviceGlyphSize = [[prefs objectForKey:@"customDeviceGlyphSize"] floatValue];
	customBatteryCellSizeEnabled = [[prefs objectForKey:@"customBatteryCellSizeEnabled"] boolValue];
	customBatteryCellSize = [[prefs objectForKey:@"customBatteryCellSize"] floatValue];
	customPercentageFontSizeEnabled = [[prefs objectForKey:@"customPercentageFontSizeEnabled"] boolValue];
	customPercentageFontSize = [[prefs objectForKey:@"customPercentageFontSize"] floatValue];
	paddingBetweenGlyphAndLabelEnabled = [[prefs objectForKey:@"paddingBetweenGlyphAndLabelEnabled"] boolValue];
	paddingBetweenGlyphAndLabel = [[prefs objectForKey:@"paddingBetweenGlyphAndLabel"] floatValue];
	horizontalSpacingBetweenDevicesEnabled = [[prefs objectForKey:@"horizontalSpacingBetweenDevicesEnabled"] boolValue];
	horizontalSpacingBetweenDevices = [[prefs objectForKey:@"horizontalSpacingBetweenDevices"] floatValue];
	customGridSwitcherAppSizeEnabled = [[prefs objectForKey:@"customGridSwitcherAppSizeEnabled"] boolValue];
	customGridSwitcherAppSize = [[prefs objectForKey:@"customGridSwitcherAppSize"] floatValue];
	customGridSwitcherSpacingEnabled = [[prefs objectForKey:@"customGridSwitcherSpacingEnabled"] boolValue];
	customGridSwitcherSpacing = [[prefs objectForKey:@"customGridSwitcherSpacing"] floatValue];
	customConnectedDeviceColorMode = [prefs objectForKey:@"customConnectedDeviceColorMode"];
	customConnectedDeviceColor = [prefs objectForKey:@"customConnectedDeviceColor"];
	customDisconnectedDeviceColorMode = [prefs objectForKey:@"customDisconnectedDeviceColorMode"];
	customDisconnectedDeviceColor = [prefs objectForKey:@"customDisconnectedDeviceColor"];
	customLowPowerColorMode = [prefs objectForKey:@"customLowPowerColorMode"];
	customLowPowerColor = [prefs objectForKey:@"customLowPowerColor"];
	customLowBatteryColorMode = [prefs objectForKey:@"customLowBatteryColorMode"];
	customLowBatteryColor = [prefs objectForKey:@"customLowBatteryColor"];
	customChargingColorMode = [prefs objectForKey:@"customChargingColorMode"];
	customChargingColor = [prefs objectForKey:@"customChargingColor"];
}

%ctor {
	prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.atar13.vaonprefs"];
	updateSettings();

	if([switcherMode isEqual:@"grid"]){
		customSwitcherStyle = 2;
	}else{
		currentSwitcherStyle = 0;
	}



	if(kCFCoreFoundationVersionNumber > 1750){
		ios13 = false;
		ios14 = true;
	} else if(kCFCoreFoundationVersionNumber > 1600) {
		ios13 = true;
		ios14 = false;
	} else {
		ios13 = false;
		ios14 = false;
	}


	// ios13 = false;
	// ios14 = true;

	if(isEnabled){
		%init;

		if([selectedModule isEqual:@"battery"]){
			%init(BatteryModeUpdates);
		
			if(ios13){
				%init(iOS13BatteryModeUpdates);

			}
		}
		// NSLog(@"%s", "Vaon: Initializing ios 14 battery update hooks");

	}
}