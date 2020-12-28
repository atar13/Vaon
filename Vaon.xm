//TODO: 
//raise app switcher

//ios 14 1751.108 

//credit to Dogbert for the icon

#import "Vaon.h"
#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

HBPreferences *prefs;

//main page preference variables
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

//battery configuration preference variables
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
BOOL doneFadingIn = FALSE;
BOOL stockHidden = TRUE;

NSArray *connectedBluetoothDevices;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];
NSMutableArray *deviceIdentifiers = [[NSMutableArray alloc] init];
NSMutableArray *deviceGlyphs = [[NSMutableArray alloc] init];

UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];

//timers to initiate animations
NSTimer *delayedFadeInTimer = nil;
NSTimer *delayedPulsateTimer = nil;

//delegate for outline animation
@implementation StrokeEndAnimationDelegate 

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell {
		self = [super init];
		self.cell = cell;
		return self;
	}

	//keeps the outline at a static position when it finishes animating
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag){
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue
							forKey:kCATransactionDisableActions];
			self.cell.circleOutlineLayer.strokeEnd = [self.cell devicePercentageAsProgress];
			[CATransaction commit];
			if(pulsateChargingOutline){
				// delayedPulsateTimer = [NSTimer scheduledTimerWithTimeInterval:1
				// 							target:self
				// 							selector:@selector(delayedPulsate)
				// 							userInfo:nil
				// 							repeats:NO];	
				[self.cell pulsateOutline];
			}
		}
	}


	-(void)delayedPulsate {
		[self.cell pulsateOutline];
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
		if(flag&&[self.cell.device isCharging]&&pulsateChargingOutline){
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
	UIColor *lowPowerModeColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
	UIColor *lowBatteryColor = [UIColor redColor];
	UIColor *brightGreen = [UIColor colorWithRed:0.1746478873 green:0.2039215686 blue:0.1960784314 alpha: 1];

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
        self.distribution = UIStackViewDistributionEqualSpacing;
        self.spacing = 10;
        self.clipsToBounds = FALSE;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = FALSE;
    
		//initialize bakcground blur effect
		self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
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
		if(customPercentageFontSizeEnabled){
        	devicePercentageLabelFont = [UIFont systemFontOfSize:customPercentageFontSize weight:UIFontWeightBold];
		} else{
        	devicePercentageLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
		}
        self.devicePercentageLabel.font = devicePercentageLabelFont;
        self.devicePercentageLabel.frame = self.bounds;
        self.devicePercentageLabel.clipsToBounds = TRUE;

		//view placement and constraints for background blur
        [self.circleBackgroundVisualEffectView.contentView addSubview:self.devicePercentageLabel];
        self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.circleBackgroundVisualEffectView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self.circleBackgroundVisualEffectView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self addArrangedSubview:self.circleBackgroundVisualEffectView];

		//view placement and constrains for battery percentage 
        self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.devicePercentageLabel.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        [self.devicePercentageLabel.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor].active = TRUE;

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
        self.deviceGlyphView = [[UIImageView alloc] initWithImage:connectedDevice.glyph];
		self.deviceGlyphView.contentMode = UIViewContentModeScaleAspectFit;
		[self.deviceGlyphView.heightAnchor constraintEqualToConstant:self.cellWidth*0.6].active = TRUE;
		
        [self addArrangedSubview:self.deviceGlyphView];
		[self.circleBackgroundVisualEffectView setNeedsDisplay];
        self.deviceName = connectedDevice.name;

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
			self.circleOutlineLayer.strokeColor = lowPowerModeColor.CGColor;
		} else if([self isBatteryLow] && (![self.device isCharging])){
			self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
		} else if([self.device isCharging] && pulsateChargingOutline){
			self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		} else {
			if(![self.device isConnected]){
				self.circleOutlineLayer.strokeColor = [UIColor systemGrayColor].CGColor;
			} else {
				self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
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

			normalToBright.fromValue = id(normalBatteryColor.CGColor);
			normalToBright.toValue = id(brightGreen.CGColor);
			normalToBright.duration = 2;
			normalToBright.timingFunction = animationColorTimingFunction;
			[normalToBright setFillMode:kCAFillModeForwards];
			[normalToBright setRemovedOnCompletion:FALSE];

			brightToNormal.fromValue = normalToBright.toValue;
			brightToNormal.toValue = id(normalBatteryColor.CGColor);
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
			self.devicePercentageLabel.textColor = normalBatteryColor;
		}else {
			self.devicePercentageLabel.textColor = [UIColor labelColor];
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
	batteryHStackView.spacing = 30;
	batteryHStackView.clipsToBounds = TRUE;

	//gather bluetooth battery information
	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

	//adds to the view hierarchy
	[view addSubview:batteryScrollView];
	[batteryScrollView addSubview:batteryHStackView];


	if(!(currentSwitcherStyle == 2)){
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
	blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
	titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
	view.clipsToBounds = TRUE;
	view.layer.cornerRadius = vaonViewCornerRadius;
	view.alpha = 0;
	view.backgroundColor = vaonViewBackgroundColor;
	
	vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	vaonBlurView.frame = view.bounds;
	vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:vaonBlurView];
}

//updates battery information 
void updateBattery(){
	//access main loop
	dispatch_async(dispatch_get_main_queue(), ^{
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

			VaonDeviceBatteryCell *newCell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			
			//checks if devices are not already on the horizontal stack and the list of device names
			if(![batteryHStackView.subviews containsObject:newCell] && ![deviceNames containsObject:newCell.deviceName]){
				//add all devices that are not the iPhone/iPad
				if(![device isInternal]){
					[subviewsToBeAdded addObject:newCell];			
					[deviceIdentifiers addObject:[newCell.device identifier]];
					[deviceNames addObject:[newCell.device name]];			
				} else{
					//displays the iphone if hideInternal is off
					if(!hideInternal){
						[subviewsToBeAdded addObject:newCell];
						[deviceIdentifiers addObject:[newCell.device identifier]];
						[deviceNames addObject:[newCell.device name]];			
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
								subview.deviceGlyphView = [[UIImageView alloc] initWithImage:subview.device.glyph];
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
}



//fade in the base Vaon view
void fadeViewIn(UIView *view, CGFloat duration){

	//stop the timer if its still running from the last time the view faded in
	if(delayedFadeInTimer!=nil){
		[delayedFadeInTimer invalidate];
	}
	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 1;
	} completion:^(BOOL finished) {
		if(view.alpha==1){
			if([selectedModule isEqual:@"battery"]){
				updateBattery();
				for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
					if(finished){
						[subview newAnimateOuterLayerToCurrentPercentage];
					}
				}
			}
		}
	}];	
	
}

//fade the base Vaon view out
void fadeViewOut(UIView *view, CGFloat duration){
	//animate all the outlines back to their original position
	for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
		[subview newAnimateOuterLayerToZero];
	}	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 0;
	} completion:^(BOOL finished) {
		stockHidden = TRUE;
	}];	
}


//update battery information and displayed data
%group BatteryModeUpdates


%hook BCBatteryDevice

	-(void)setCharging: (BOOL)arg1 {
		%orig;
		updateBattery();
	}
	-(void)setBatterSaveModeActive:(BOOL)arg1 {
		updateBattery();
		%orig;
	}
	-(void)setPercentCharge:(NSInteger)arg1 {
		if(arg1!=0){
			updateBattery();
		}
		%orig;
	}
	-(void)dealloc {
		%orig;
		updateBattery();
	}
 
 %end

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

				//vaon view constraints and placement
				vaonView.translatesAutoresizingMaskIntoConstraints = false;
				if(customVerticalOffsetEnabled){
					[vaonView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-customVerticalOffset].active = TRUE;
				} else{
					[vaonView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-80].active = TRUE;
				}
				[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
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

			//opening the app switcher from the home screen
			if(currentAppDisplayID==nil){
				fadeViewIn(vaonView, 0.3);
			} else {
				if(stockHidden){
					//opening the app switcher from an app 
					delayedFadeInTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
												target:self
												selector:@selector(fadeInFromApp)
												userInfo:nil
												repeats:NO];	
				} 
			}
		}
	}

	%new 
	-(void)fadeInFromApp {
		fadeViewIn(vaonView, 0.3);
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

					//grid mode constraints and vaon view placement
					vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
					if(customVerticalOffsetEnabled){
						[vaonGridView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:customVerticalOffset].active = TRUE;
					} else{
						[vaonGridView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-80].active = TRUE;
					}
					[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = TRUE;
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

	
	-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
		if (arg2 == FALSE && ![selectedModule isEqual:@"none"]) {
			fadeViewOut(vaonView, 0.2);
		}
		%orig;
	}


	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {
		if(![selectedModule isEqual:@"none"] && customSwitcherStyle != 2){
			NSString *switcherTransitionRequest = [[NSString alloc] initWithFormat:@"%@", arg2];
			NSUInteger indexAfterAppLayout =  [switcherTransitionRequest rangeOfString: @"appLayout: "].location;
			NSString *appLayoutString = [switcherTransitionRequest substringFromIndex:indexAfterAppLayout];
			// FinalFluidSwitcherGestureAction
			NSString *eventLabel = [[NSString alloc] initWithFormat:@"%@", arg3];

			//only for stock switcher
			if(![appLayoutString containsString:@"appLayout: 0x0;"]){		
				fadeViewOut(vaonView, 0.2);
			}
			if([eventLabel isEqual:@"FinalFluidSwitcherGestureAction"]&&mainAppSwitcherVC.sbActiveInterfaceOrientation==1){

				//uncommenting this makes the animation begin before the view appears but doesnt fade in when the switcher is launched
				//from an app
				//need to look into why this runs in stock mode
				// fadeViewIn(vaonView, 2);
			}
		}
		%orig;
	}




	//fade in and out for vaon in grid mode
	-(void)_updateDisplayLayoutElementForLayoutState: (id)arg1 {
		%orig;
		if(![selectedModule isEqual:@"none"]){
			appSwitcherOpen = [self isAnySwitcherVisible];
			if(currentSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
				if(!appSwitcherOpen){
					fadeViewOut(vaonGridView, 0.3);
				}else{
					if(!(vaonGridView.alpha==1)){
						fadeViewIn(vaonGridView, 0.3);
					}
				}
			}
		}
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
		%orig(0.25);
	}

	-(void)setGridSwitcherVerticalNaturalSpacingPortrait: (double)arg1 {
		%orig(40);
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

//displays vaon when no apps are open
%hook SBFluidSwitcherAnimationSettings
	-(void)setEmptySwitcherDismissDelay:(double)arg1 {
		%orig(2);
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
	[prefs registerBool:&isEnabled default:TRUE forKey:@"isEnabled"];
	[prefs registerObject:&switcherMode default:@"stock" forKey:@"switcherMode"];
	[prefs registerObject:&selectedModule default:@"battery" forKey:@"moduleSelection"];
	[prefs registerBool:&hideAppTitles default:FALSE forKey:@"hideAppTitles"];
	[prefs registerBool:&hideSuggestionBanner default:TRUE forKey:@"hideSuggestionBanner"];
	[prefs registerBool:&customHeightEnabled default:FALSE forKey:@"customHeightEnabled"];
	[prefs registerFloat:&customHeight default:113 forKey:@"customHeight"];
	[prefs registerBool:&customWidthEnabled default:FALSE forKey:@"customWidthEnabled"];
	[prefs registerFloat:&customWidth default:400 forKey:@"customWidth"];
	[prefs registerBool:&customVerticalOffsetEnabled default:FALSE forKey:@"customVerticalOffsetEnabled"];
	[prefs registerFloat:&customVerticalOffset default:-80 forKey:@"customVerticalOffset"];

	[prefs registerBool:&hideInternal default:FALSE forKey:@"hideInternal"];
	[prefs registerBool:&hidePercent default:FALSE forKey:@"hidePercent"];
	[prefs registerBool:&roundOutlineCorners default:TRUE forKey:@"roundOutlineCorners"];
	[prefs registerBool:&pulsateChargingOutline default:FALSE forKey:@"pulsateChargingOutline"];
	[prefs registerBool:&keepDisconnectedDevices default:TRUE forKey:@"keepDisconnectedDevices"];
	[prefs registerBool:&customBatteryCellSizeEnabled default:FALSE forKey:@"customBatteryCellSizeEnabled"];
	[prefs registerFloat:&customBatteryCellSize default:50 forKey:@"customBatteryCellSize"];
	[prefs registerBool:&customPercentageFontSizeEnabled default:FALSE forKey:@"customPercentageFontSizeEnabled"];
	[prefs registerFloat:&customPercentageFontSize default:12 forKey:@"customPercentageFontSize"];
}

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	updateSettings();

	if([switcherMode isEqual:@"grid"]){
		customSwitcherStyle = 2;
	}else{
		currentSwitcherStyle = 0;
	}

	if(isEnabled){
		%init;
		if([selectedModule isEqual:@"battery"]){
			%init(BatteryModeUpdates);
		}
	}

	


}
/**
Additional modules:
favorite contacts or an option for recents
device batteries
favorited apps
music player when you 
countdown 
airpod pro transparency and noise cancellation
weather/AQI view that's similar to battery view
**/