//TODO: 
//add customtext option to the top/bottom of vaon view
//option for a split view of two widgets
//add option for vaon to fly up from the bottom	
//add option to ovveride landscape hide and override hiding the suggestion banner
//hide appname/icon from sbappswitchersettings
//options for custom placement and resizing
//make social media icons filled and grey/colorful
//option to hide percent character
//change color of outline depending on percentage
//async functions to update device count, check to see if current device list has changed (if it has load new stack view elements), refresh the outline, refresh label and glyphs
//OR have the fade out function remove all the stack views and then every fade in would re make them
//align circle/outline views on the same axis
//outline doesn't update
//raise app switcher
//option to hide app header titles
/**
favorite contacts or an option for recents
device batteries
favorited apps
music player when you 
countdown 
airpod pro transparency and noise cancellation
weather/AQI view that's similar to battery view
**/

//credit to Dogbert for the icon


#import <Cephei/HBPreferences.h>
#import <Vaon.h>
#import <QuartzCore/QuartzCore.h>


HBPreferences *prefs;

//preference variables
BOOL isEnabled;
NSString *switcherMode = nil;
NSString *selectedModule = nil;
BOOL hideSuggestionBanner;
BOOL customHeightEnabled;
CGFloat customHeight;
BOOL customWidthEnabled;
CGFloat customWidth;

BOOL hideInternal;
BOOL hidePercent;
BOOL pulsateChargingOutline;
BOOL customBatteryCellSizeEnabled;
CGFloat customBatteryCellSize; 
BOOL customPercentageFontSizeEnabled;
CGFloat customPercentageFontSize;

UIView *vaonView;
UIView *vaonGridView;

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


@implementation StrokeEndAnimationDelegate 

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell {
		self = [super init];
		self.cell = cell;
		return self;
	}
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag){
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue
							forKey:kCATransactionDisableActions];
			self.cell.circleOutlineLayer.strokeEnd = [self.cell devicePercentageAsProgress];
			[CATransaction commit];
			if(pulsateChargingOutline){
				[self.cell pulsateOutline];
			}
		}
	}

@end

@implementation PulsateColorAnimationDelegate

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell nextAnimation:(CAAnimation *)nextAnimation {
		self = [super init];
		self.cell = cell;
		self.nextAnimation = nextAnimation;
		return self;
	}
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag&&[self.cell.device isCharging]&&pulsateChargingOutline){
			
			[self.cell.circleOutlineLayer addAnimation:self.nextAnimation forKey:kCATransition];
			

		}
	}

@end

@implementation VaonDeviceBatteryCell
	UIColor *lowPowerModeColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
	UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];
	UIColor *lowBatteryColor = [UIColor redColor];
	UIColor *brightGreen = [UIColor colorWithRed:0.1746478873 green:0.2039215686 blue:0.1960784314 alpha: 1];
	// UIColor *brightGreen = [UIColor blackColor];

    -(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)connectedDevice {
        self.device = connectedDevice;
		if(customBatteryCellSizeEnabled){
        	self.cellWidth = CGFloat(customBatteryCellSize);
		} else {
			self.cellWidth = CGFloat(50);
		}
        self.devicePercentage = [connectedDevice percentCharge];

        self = [super initWithFrame:arg1];
        self.axis = UILayoutConstraintAxisVertical;
        self.alignment = UIStackViewAlignmentCenter;
        self.distribution = UIStackViewDistributionEqualSpacing;
        self.spacing = 10;
        self.clipsToBounds = FALSE;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = FALSE;
    
		self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        self.circleBackgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:self.circleBackgroundBlurEffect];
        self.circleBackgroundVisualEffectView.layer.cornerRadius = self.cellWidth/2;
        self.circleBackgroundVisualEffectView.clipsToBounds = TRUE;
        self.circleBackgroundVisualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.circleBackgroundVisualEffectView.frame = self.bounds;
       	self.circleBackgroundVisualEffectView.contentMode = UIViewContentModeScaleAspectFill;


        self.devicePercentageLabel = [[UILabel alloc] init];
        // self.devicePercentageString = [NSMutableString stringWithFormat: @"%lld", [self devicePercentage]]; 
        // self.devicePercentageLabel.text =;
        [self updateDevicePercentageLabel];
        [self addPercentageSymbolToLabel];
        self.devicePercentageLabel.numberOfLines = 1;
		UIFont *devicePercentageLabelFont = [[UIFont alloc] init];
		if(customPercentageFontSizeEnabled){
        	devicePercentageLabelFont = [UIFont systemFontOfSize:customPercentageFontSize weight:UIFontWeightBold];
		} else{
        	devicePercentageLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
		}
        self.devicePercentageLabel.font = devicePercentageLabelFont;
		// self.devicePercentageLabel.adjustsFontSizeToFitWidth = TRUE;
        self.devicePercentageLabel.frame = self.bounds;
        self.devicePercentageLabel.clipsToBounds = TRUE;



        [self.circleBackgroundVisualEffectView.contentView addSubview:self.devicePercentageLabel];

        self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.circleBackgroundVisualEffectView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self.circleBackgroundVisualEffectView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
		// self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
		// [self.devicePercentageLabel.widthAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.widthAnchor].active = TRUE;
		// [self.devicePercentageLabel.heightAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.heightAnchor].active = TRUE;

        [self addArrangedSubview:self.circleBackgroundVisualEffectView];

        self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.devicePercentageLabel.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        [self.devicePercentageLabel.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor].active = TRUE;

        // self.circleOutlinePath = [UIBezierPath bezierPath];
        self.circleOutlinePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleBackgroundVisualEffectView.contentView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.contentView.center.y+self.cellWidth/2)
            radius:self.cellWidth/2
            startAngle:[self degreesToRadians:(-90)]
            endAngle:[self degreesToRadians:(270)]
            clockwise:TRUE];
		// self.circleOutlinePath = [UIBezierPath bezierPathWithOvalInRect:self.circleBackgroundVisualEffectView.contentView.bounds];


        self.circleOutlineLayer = [[CAShapeLayer alloc] init];
        self.circleOutlineLayer.bounds = self.bounds;
        // self.circleOutlineLayer.position = self.circleBackgroundVisualEffectView.contentView.center;
        self.circleOutlineLayer.fillColor = [UIColor clearColor].CGColor;
        // self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		self.circleOutlineLayer.strokeStart = 0;
		self.circleOutlineLayer.strokeEnd = 0;
        self.circleOutlineLayer.path = [self.circleOutlinePath CGPath];
        self.circleOutlineLayer.lineWidth = self.cellWidth/10;
		self.circleOutlineLayer.masksToBounds = FALSE;
        [self.layer addSublayer:self.circleOutlineLayer];
	

        self.deviceGlyphView = [[UIImageView alloc] initWithImage:connectedDevice.glyph];
		// [self.deviceGlyphView.widthAnchor constraintEqualToConstant:50].active = TRUE;
		self.deviceGlyphView.contentMode = UIViewContentModeScaleAspectFit;
		[self.deviceGlyphView.heightAnchor constraintEqualToConstant:self.cellWidth*0.6].active = TRUE;
		
        [self addArrangedSubview:self.deviceGlyphView];
		// [self.circleOutlineLayer setNeedsDisplay];
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
    -(void)updateDevicePercentageLabel {
		[self updateDevicePercentage];
        self.devicePercentageString = [NSMutableString stringWithFormat:@"%lld",self.devicePercentage];
		[self addPercentageSymbolToLabel];

        // self.devicePercentageString = string;
        self.devicePercentageLabel.text = self.devicePercentageString;
    }

	-(void)updateCircleOutline {
		// self.circleOutlinePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleBackgroundVisualEffectView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.center.y+self.cellWidth/2)
        //     radius:self.cellWidth/2
        //     startAngle:[self degreesToRadians:(-90)]
        //     endAngle:[self degreesToRadians:(3.6*(self.devicePercentage)-90)]
        //     clockwise:TRUE];

		[self.circleOutlineLayer setNeedsDisplay];
	}

	// -(void)animateOutlineLayer:(CGFloat)progress {
	// 	self.circleOutlineLayer.strokeEnd = progress;
	// }
	-(void)resetStrokeEnd {
		self.circleOutlineLayer.strokeEnd = 0;
	}
	-(void)removeFromSuperview {
		[super removeFromSuperview];
	}
	-(CGFloat)devicePercentageAsProgress {
		double progress = [self getDevicePercentage];
		return progress/100;
	}
	-(BOOL)isDeviceInternal {
		return [self.device isInternal];
	}
	-(BOOL)isLowPowerModeOn {
		return [self.device isBatterySaverModeActive];
	}
	-(BOOL)isBatteryLow {
		return [self.device isLowBattery];
	}
	-(void)updateOutlineColor {
		if([self isDeviceInternal]&&[self isLowPowerModeOn]&&![self.device isCharging]){
			self.circleOutlineLayer.strokeColor = lowPowerModeColor.CGColor;
		} else if([self isBatteryLow]&&(![self.device isCharging])){
			self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
		} else if([self.device isCharging]&&pulsateChargingOutline){
			// self.circleOutlineLayer.strokeColor = nil;
		} else {
			self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		}
	}
	-(void)pulsateOutline {
		if([self.device isCharging]){
			CAMediaTimingFunction *animationColorTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

			CABasicAnimation *normalToBright = [CABasicAnimation animationWithKeyPath:@"strokeColor"];	
			CABasicAnimation *brightToNormal = [CABasicAnimation animationWithKeyPath:@"strokeColor"];

			PulsateColorAnimationDelegate *normalToBrightDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:brightToNormal];
			normalToBright.delegate = normalToBrightDelegate;
			PulsateColorAnimationDelegate *brightToNormalDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:normalToBright];
			brightToNormal.delegate = brightToNormalDelegate;

			normalToBright.fromValue = id(normalBatteryColor.CGColor);
			normalToBright.toValue = id(brightGreen.CGColor);
			normalToBright.duration = 1;
			normalToBright.timingFunction = animationColorTimingFunction;
			normalToBright.fillMode = kCAFillModeForwards;
			normalToBright.removedOnCompletion = TRUE;

			brightToNormal.fromValue = normalToBright.toValue;
			brightToNormal.toValue = id(normalBatteryColor.CGColor);
			brightToNormal.duration = 1;
			brightToNormal.timingFunction = animationColorTimingFunction;
			brightToNormal.fillMode = kCAFillModeForwards;
			brightToNormal.removedOnCompletion = TRUE;

			[self.circleOutlineLayer addAnimation:normalToBright forKey:kCATransition];
		}
	}
	-(void)updatePercentageColor {
		if([self.device isCharging]){
			self.devicePercentageLabel.textColor = normalBatteryColor;
		}else {
			self.devicePercentageLabel.textColor = [UIColor labelColor];

		}
	}
	-(void)newAnimateOuterLayerToCurrentPercentage{
		self.percentageAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		StrokeEndAnimationDelegate *delegate = [[StrokeEndAnimationDelegate alloc] initWithCell:self];
		self.percentageAnimation.delegate = delegate;
		self.percentageAnimation.fromValue = @(0.0);
		self.percentageAnimation.toValue = @([self devicePercentageAsProgress]);
		self.percentageAnimation.duration = 0.3;
		CAMediaTimingFunction *animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		self.percentageAnimation.timingFunction = animationTimingFunction;
		
		[self.circleOutlineLayer addAnimation:self.percentageAnimation forKey:kCATransition];
	}
	-(void)newAnimateOuterLayerToZero {
		self.circleOutlineLayer.strokeEnd = 0;
	}


@end

@implementation VaonFavoriteContactsCell

-(instancetype)initWithFrame:(CGRect)arg1 favoriteEntry:(CNFavoriteEntry *)favoriteEntry {
	self = [super initWithFrame:arg1];
	self.axis = UILayoutConstraintAxisVertical;
	self.alignment = UIStackViewAlignmentCenter;
	self.distribution = UIStackViewDistributionEqualSpacing;
	self.spacing = 10;
	self.clipsToBounds = TRUE;
	self.backgroundColor = [UIColor clearColor];
	self.translatesAutoresizingMaskIntoConstraints = FALSE;

	self.favoriteEntry = favoriteEntry;
	self.contact = favoriteEntry.contact;


	self.contactNameLabel = [[UILabel alloc] init];
	self.contactNameLabel.text = [self.favoriteEntry originalName];
	self.contactNameLabel.adjustsFontSizeToFitWidth = TRUE;
	self.contactNameLabel.frame = self.bounds;
	self.contactNameLabel.clipsToBounds = TRUE;

	[self addArrangedSubview:self.contactNameLabel];

	NSData *imageData = self.contact.imageData;

	UIImage *contactImage = [UIImage imageWithData:imageData];
	self.contactImageView = [[UIImageView alloc] initWithImage:contactImage];
	self.contactImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.contactImageView.frame = self.bounds;
	self.contactImageView.clipsToBounds = TRUE;

	[self addArrangedSubview:self.contactImageView];

	return self;
}


@end







void initBatteryView(UIView *view){

	batteryHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
	batteryHStackView.axis = UILayoutConstraintAxisHorizontal;
	batteryHStackView.alignment = UIStackViewAlignmentCenter;
	batteryHStackView.distribution = UIStackViewDistributionFill;
	batteryHStackView.spacing = 30;
	batteryHStackView.clipsToBounds = TRUE;

	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];


	[view addSubview:batteryHStackView];

	if(!(currentSwitcherStyle==2)){
		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *cell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			[batteryHStackView addArrangedSubview:cell]; 
		}
	}

	batteryHStackView.translatesAutoresizingMaskIntoConstraints = false;

	[batteryHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;

}



void initFavoriteContactsView(UIView *view) {
	// favoriteContactsScrollView

	favoriteContactsHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
	favoriteContactsHStackView.axis = UILayoutConstraintAxisHorizontal;
	favoriteContactsHStackView.alignment = UIStackViewAlignmentCenter;
	favoriteContactsHStackView.distribution = UIStackViewDistributionEqualCentering;
	favoriteContactsHStackView.spacing = 80;
	favoriteContactsHStackView.clipsToBounds = TRUE;

	[view addSubview:favoriteContactsHStackView];

	NSArray *contactFavorites = [[%c(CNFavorites) sharedInstance] entries];

	for(CNFavoriteEntry *entry in contactFavorites){
		VaonFavoriteContactsCell *cell = [[VaonFavoriteContactsCell alloc] initWithFrame:favoriteContactsHStackView.bounds favoriteEntry:entry];
		[favoriteContactsHStackView addArrangedSubview:cell];
	}

	favoriteContactsHStackView.translatesAutoresizingMaskIntoConstraints = false;

	[favoriteContactsHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[favoriteContactsHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;
}


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

void updateBattery(){
	dispatch_async(dispatch_get_main_queue(), ^{

		//check if product identifier/acessory identifier already exists in hstackview

		connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		NSMutableArray *subviewsToBeAdded = [[NSMutableArray alloc] init];



		// connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *newCell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			NSMutableArray *cellDevices = [[NSMutableArray alloc] init];
			for(VaonDeviceBatteryCell *cell in batteryHStackView.subviews){
				if(!(cell.device==nil)){
					[cellDevices addObject:cell.device];
				}
			}
			if((![batteryHStackView.subviews containsObject:newCell]&&![deviceNames containsObject:device.name])&&batteryHStackView.subviews.count<6){
				if(![device isInternal]){
					[subviewsToBeAdded addObject:newCell];
					[deviceNames addObject:newCell.deviceName];
				}else{
					if(!hideInternal){
						[subviewsToBeAdded addObject:newCell];
						[deviceNames addObject:newCell.deviceName];
					}
				}
			}
		}

		for(VaonDeviceBatteryCell *subview in subviewsToBeAdded){

			[batteryHStackView addArrangedSubview:subview];

			subview.alpha = 0;
			[UIView animateWithDuration:0.3 animations:^ {
				subview.alpha = 1;

			}
			completion:^(BOOL finished) {
				[subview newAnimateOuterLayerToCurrentPercentage];
				[subviewsToBeAdded removeObject:subview];
			}];	
		}

		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
					// connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
			if((![connectedBluetoothDevices containsObject:subview.device] && ![subview.device isConnected]) || subview.device == nil ){
				subview.alpha = 1;
				[UIView animateWithDuration:0.3 animations:^ {
					subview.alpha = 0;
				}
				completion:^(BOOL finished) {
					[subview removeFromSuperview];
					// [batteryHStackView removeArrangedSubview:subview];
					[deviceNames removeObject:subview.deviceName];				
				}];	
			}
			[subview updateDevicePercentageLabel];
			// [subview animateOutlineLayer:[subview devicePercentageAsProgress]];
			[subview updateOutlineColor];
			[subview updatePercentageColor];
			// [subview updateCircleOutline];
		}

	}); 
}



void fadeViewIn(UIView *view, CGFloat duration){
	if(doneFadingIn==FALSE){
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 1;
	} 	
	completion:^(BOOL finished) {
		if([selectedModule isEqual:@"battery"]){
			updateBattery();
			if(fadeInCounter==0){

			for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
				if(finished){
						[subview newAnimateOuterLayerToCurrentPercentage];
					}
				}
				fadeInCounter++;
			}
		}
		doneFadingIn = TRUE;
	}];	
	}
}

void fadeViewOut(UIView *view, CGFloat duration){
	for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
				[subview newAnimateOuterLayerToZero];
	}	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 0;
	}
	completion:^(BOOL finished) {
		fadeInCounter = 0;
		if([selectedModule isEqual:@"battery"]){


		}
		doneFadingIn = FALSE;
	}];	
}




%group BatteryModeUpdates


%hook BCBatteryDevice

//maybe add -(void)_postDidChangeNotification;, -(void)addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;, -(void)_queue_addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;
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
			if(!vaonViewIsInitialized&&!(currentSwitcherStyle==2)){

				vaonView = [[UIView alloc] init];

				initBaseVaonView(vaonView);

				if([selectedModule isEqual:@"battery"]){	
					initBatteryView(vaonView);
				}else if([selectedModule isEqual:@"favoriteContacts"]){
					initFavoriteContactsView(vaonView);
				}

				[self addSubview:vaonView];

				vaonView.translatesAutoresizingMaskIntoConstraints = false;
				[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = TRUE;
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
				if(mainAppSwitcherVC.sbActiveInterfaceOrientation==1){
					fadeViewIn(vaonView, 0.3);

				}
			}	
		}
		
	}
%end


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
						initFavoriteContactsView(vaonGridView);
					}
					
					[self.view addSubview:vaonGridView];

					vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
					[vaonGridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-23].active = TRUE;
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
			// [UIView animateWithDuration:0.2 animations:^ {
			// 	vaonView.alpha = 0;
			// }];
			fadeViewOut(vaonView, 0.2);
		}
		%orig;
	}


	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {
		if(![selectedModule isEqual:@"none"]){
			NSString *switcherTransitionRequest = [[NSString alloc] initWithFormat:@"%@", arg2];
			NSUInteger indexAfterAppLayout =  [switcherTransitionRequest rangeOfString: @"appLayout: "].location;
			NSString *appLayoutString = [switcherTransitionRequest substringFromIndex:indexAfterAppLayout];
			// FinalFluidSwitcherGestureAction
			NSString *eventLabel = [[NSString alloc] initWithFormat:@"%@", arg3];

			// if(!(currentSwitcherStyle==2)){
			if(![appLayoutString containsString:@"appLayout: 0x0;"]){		
				// [UIView animateWithDuration:0.2 animations:^ {
				// 	vaonView.alpha = 0;
				// }];
				fadeViewOut(vaonView, 0.2);
			}
			if([eventLabel isEqual:@"FinalFluidSwitcherGestureAction"]&&mainAppSwitcherVC.sbActiveInterfaceOrientation==1){

				fadeViewIn(vaonView, 0.3);


			}
			// }
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
				// if(doneFadingIn){
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

	-(void)didMoveToWindow {
		%orig;
		if(hideSuggestionBanner){
			self.hidden = TRUE;
		}
	}
%end

%hook SBFluidSwitcherItemContainerHeaderView


	-(void)addSubview {
		%orig;
		// self.hidden = TRUE;
	}
%end

%hook SBFluidSwitcherItemContainer

	- (void)setTitleOpacity:(double)arg1 {
		%orig(0);
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

// %hook SBHomeGestureSettings

// 	- (void)setMinimumYDistanceForHomeOrAppSwitcher:(double)arg1 {
// 	    %orig(0);
// }

// %end

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
	[prefs registerBool:&hideSuggestionBanner default:TRUE forKey:@"hideSuggestionBanner"];
	[prefs registerBool:&customHeightEnabled default:FALSE forKey:@"customHeightEnabled"];
	[prefs registerFloat:&customHeight default:113 forKey:@"customHeight"];
	[prefs registerBool:&customWidthEnabled default:FALSE forKey:@"customWidthEnabled"];
	[prefs registerFloat:&customWidth default:400 forKey:@"customWidth"];

	[prefs registerBool:&hideInternal default:FALSE forKey:@"hideInternal"];
	[prefs registerBool:&hidePercent default:FALSE forKey:@"hidePercent"];
	[prefs registerBool:&pulsateChargingOutline default:FALSE forKey:@"pulsateChargingOutline"];
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