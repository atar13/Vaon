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

BOOL hideInternal;
BOOL hidePercent;

UIView *vaonView;
UIView *vaonGridView;

UIStackView *batteryHStackView;

UIColor *vaonViewBackgroundColor;
UIVisualEffectView *vaonBlurView;
UIBlurEffect *blurEffect;
UILabel *titleLabel;

int vaonViewCornerRadius = 17;

CGFloat dockWidth;
BOOL vaonViewIsInitialized = FALSE;

// long long sbAppSwitcherOrientation;
SBMainSwitcherViewController *mainAppSwitcherVC;
long long customSwitcherStyle = 2;
BOOL appSwitcherOpen = FALSE;
int fadeInCounter = 0;

//batteryView variables
NSArray *connectedBluetoothDevices;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];


@implementation CAAnimationDelegate 

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
		}
	}

@end

@implementation VaonDeviceBatteryCell
	UIColor *lowPowerModeColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
	UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];
	UIColor *lowBatteryColor = [UIColor redColor];

    -(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)connectedDevice {
        self.device = connectedDevice;
        self.cellWidth = CGFloat(50);
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
        UIFont *devicePercentageLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        self.devicePercentageLabel.font = devicePercentageLabelFont;
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
        self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
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
		if([self isDeviceInternal]&&[self isLowPowerModeOn]){
			self.circleOutlineLayer.strokeColor = lowPowerModeColor.CGColor;
		} else if([self isBatteryLow]){
			self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
		} else {
			self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		}
	}
	-(void)pulsateOutline:(BOOL)start {
		//doesnt work yet
		// if(start){
			// [UIView animateWithDuration:0.5 animations:^{
			// 	self.circleOutlineLayer.strokeColor = [UIColor greenColor].CGColor;
			// }];
			[UIView animateWithDuration:10 animations:^{
				self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
			}completion:^(BOOL finished) {
								[UIView animateWithDuration:0.5 animations:^{
					self.circleOutlineLayer.strokeColor = [UIColor greenColor].CGColor;
				}completion:^(BOOL fin) {
								[UIView animateWithDuration:0.5 animations:^{
				self.circleOutlineLayer.strokeColor = [UIColor blueColor].CGColor;
			}];
				}];
			}
			];	
			// [UIView animateWithDuration:0.5 animations:^{
			// 	self.circleOutlineLayer.strokeColor = [UIColor greenColor].CGColor;
			// }];
		// }else{
		// 	self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		// }
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
		CAAnimationDelegate *delegate = [[CAAnimationDelegate alloc] initWithCell:self];
		self.percentageAnimation.delegate = delegate;
		self.percentageAnimation.fromValue = @(0.0);
		self.percentageAnimation.toValue = @([self devicePercentageAsProgress]);
		self.percentageAnimation.duration = 0.5;
		CAMediaTimingFunction *animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		self.percentageAnimation.timingFunction = animationTimingFunction;
		
		[self.circleOutlineLayer addAnimation:self.percentageAnimation forKey:kCATransition];
	}
	-(void)newAnimateOuterLayerToZero {
		self.circleOutlineLayer.strokeEnd = 0;
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

	if(!(customSwitcherStyle==2)){
		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *cell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			[batteryHStackView addArrangedSubview:cell]; 
		}
	}

	batteryHStackView.translatesAutoresizingMaskIntoConstraints = false;

	[batteryHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;

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
			if((![batteryHStackView.subviews containsObject:newCell]&&![deviceNames containsObject:device.name])&&![cellDevices containsObject:device]&&batteryHStackView.subviews.count<6){
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
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 1;
	} 	
	completion:^(BOOL finished) {
		if([selectedModule isEqual:@"battery"]){
			updateBattery();
			if(fadeInCounter==0){

			for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
				if(!(subview.circleOutlineLayer.strokeEnd==[subview devicePercentageAsProgress])&&subview.circleOutlineLayer.strokeEnd==0){
						[subview newAnimateOuterLayerToCurrentPercentage];
					}
				}
				fadeInCounter++;
			}
		}
	}];	
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
			if(!vaonViewIsInitialized&&!(customSwitcherStyle==2)){

				vaonView = [[UIView alloc] init];

				initBaseVaonView(vaonView);

				if([selectedModule isEqual:@"battery"]){	
					initBatteryView(vaonView);
				}

				[self addSubview:vaonView];

				vaonView.translatesAutoresizingMaskIntoConstraints = false;
				[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = TRUE;
				[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
				[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
				[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = TRUE;


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
			if(customSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
				if(!vaonViewIsInitialized){
					vaonGridView = [[UIView alloc] init];

					initBaseVaonView(vaonGridView);

					if([selectedModule isEqual:@"battery"]){	
						initBatteryView(vaonGridView);
					}
					
					[self.view addSubview:vaonGridView];

					vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
					[vaonGridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-23].active = TRUE;
					[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = TRUE;
					[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
					[vaonGridView.heightAnchor constraintEqualToConstant:113].active = TRUE;

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

			// if(!(customSwitcherStyle==2)){
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
			if(customSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
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
		%orig(customSwitcherStyle);
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




void updateSettings(){
	[prefs registerBool:&isEnabled default:TRUE forKey:@"isEnabled"];
	[prefs registerObject:&switcherMode default:@"stock" forKey:@"switcherMode"];
	[prefs registerObject:&selectedModule default:@"battery" forKey:@"moduleSelection"];
	[prefs registerBool:&hideSuggestionBanner default:TRUE forKey:@"hideSuggestionBanner"];


	[prefs registerBool:&hideInternal default:FALSE forKey:@"hideInternal"];
	[prefs registerBool:&hidePercent default:FALSE forKey:@"hidePercent"];

}

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	updateSettings();

	if(isEnabled){
		%init;
		if([selectedModule isEqual:@"battery"]){
			%init(BatteryModeUpdates);
		}
	}

	if([switcherMode isEqual:@"grid"]){
		customSwitcherStyle = 2;
	}else{
		customSwitcherStyle = 1;
	}

}