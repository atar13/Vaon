//TODO: 
//add customtext option to the top/bottom of vaon view
//option for a split view of two widgets
//option to have ipad style switcher : DONE
//check for landscape mode : DONE
//add option to remove handoff/suggested apps banner that interferes with vaon : DONE
//add option for vaon to fly up from the bottom	
//add option to ovveride landscape hide and override hiding the suggestion banner
//hide appname/icon from sbappswitchersettings
//options for custom placement and resizing
//make social media icons filled and grey/colorful
//ANIMATE GREEN BATTERY CIRCLES using CGContextAddArc
//when fading in and out force the battery view to also refresh
//option to hide percent character
//change color of outline depending on percentage
//async functions to update device count, check to see if current device list has changed (if it has load new stack view elements), refresh the outline, refresh label and glyphs
//OR have the fade out function remove all the stack views and then every fade in would re make them
//align circle/outline views on the same axis
//fade in from normal app switcher app layout 
/**
recent  phone calls
favorite contacts
device batteries
favorited apps
music player
countdown 
airpod pro transparency and noise cancellation
weather/AQI view that's similar to battery view
**/

//credit to Dogbert for the icon


#import <Cephei/HBPreferences.h>
#import <Vaon.h>
#import <QuartzCore/QuartzCore.h>

@implementation VaonDeviceBatteryCell

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
		self.circleBackgroundVisualEffectView.frame = self.circleBackgroundView.bounds;
       	self.circleBackgroundVisualEffectView.contentMode = UIViewContentModeScaleAspectFill;

	    self.circleBackgroundView = [[UIView alloc] init];
        self.circleBackgroundView.frame = self.bounds;
        self.circleBackgroundView.backgroundColor = [UIColor clearColor];
        self.circleBackgroundView.layer.cornerRadius = self.cellWidth/2;
		self.circleBackgroundView.clipsToBounds = TRUE;

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



        // [self.circleBackgroundView addSubview:self.circleBackgroundVisualEffectView];
        [self.circleBackgroundVisualEffectView.contentView addSubview:self.devicePercentageLabel];

        // self.circleBackgroundView.translatesAutoresizingMaskIntoConstraints = FALSE;
        // [self.circleBackgroundView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        // [self.circleBackgroundView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        // [self addArrangedSubview:self.circleBackgroundVisualEffectView];

        self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.circleBackgroundVisualEffectView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self.circleBackgroundVisualEffectView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
		// self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
		// [self.devicePercentageLabel.widthAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.widthAnchor].active = TRUE;
		// [self.devicePercentageLabel.heightAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.heightAnchor].active = TRUE;

        [self addArrangedSubview:self.circleBackgroundVisualEffectView];

		// self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
		// [self.circleBackgroundVisualEffectView.centerXAnchor constraintEqualToAnchor:self.circleBackgroundView.centerXAnchor].active = TRUE;
		// [self.circleBackgroundVisualEffectView.centerYAnchor constraintEqualToAnchor:self.circleBackgroundView.centerYAnchor].active = TRUE;

        self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.devicePercentageLabel.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        [self.devicePercentageLabel.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor].active = TRUE;

        self.circleOutlinePath = [UIBezierPath bezierPath];
        [self.circleOutlinePath addArcWithCenter:CGPointMake(self.circleBackgroundVisualEffectView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.center.y+self.cellWidth/2)
            radius:self.cellWidth/2
            startAngle:[self degreesToRadians:(-90)]
            endAngle:[self degreesToRadians:(3.6*(self.devicePercentage)-90)]
            clockwise:TRUE];
	

        self.circleOutlineLayer = [[CAShapeLayer alloc] init];
        self.circleOutlineLayer.bounds = self.circleBackgroundVisualEffectView.bounds;
        self.circleOutlineLayer.position = self.circleBackgroundVisualEffectView.center;
        self.circleOutlineLayer.fillColor = [UIColor clearColor].CGColor;
        self.circleOutlineLayer.strokeColor = [UIColor greenColor].CGColor;
		// self.circleOutlineLayer.strokeEnd = 0;
        self.circleOutlineLayer.path = [self.circleOutlinePath CGPath];
        self.circleOutlineLayer.lineWidth = self.cellWidth/10;
		self.circleOutlineLayer.masksToBounds = FALSE;
        [self.layer addSublayer:self.circleOutlineLayer];
	

        self.deviceGlyphView = [[UIImageView alloc] initWithImage:connectedDevice.glyph];
		// [self.deviceGlyphView.widthAnchor constraintEqualToConstant:50].active = TRUE;
		// [self.deviceGlyphView.heightAnchor constraintEqualToConstant:50].active = TRUE;
		
        [self addArrangedSubview:self.deviceGlyphView];
		[self.circleOutlineLayer setNeedsDisplay];
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
        [self.devicePercentageString appendString:@"%"];
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
        self.circleOutlineLayer.path = [self.circleOutlinePath CGPath];
		[self.circleOutlineLayer setNeedsDisplay];
	}

	-(void)animateOutlineLayer:(CGFloat)progress {
		self.circleOutlineLayer.strokeEnd = progress;
	}
	-(void)resetStrokeEnd {
		self.circleOutlineLayer.strokeEnd = 0;
	}
	-(void)removeFromSuperview {
		[super removeFromSuperview];
	}

	// -(void)setNeedsDisplay:(BOOL)arg1 {
	// 	[super setNeedsDisplay:arg1];
	// }

@end





HBPreferences *prefs;

//preference variables
BOOL isEnabled;

NSString *switcherMode = nil;

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

UIDeviceOrientation deviceOrientation;
// long long sbAppSwitcherOrientation;
SBMainSwitcherViewController *mainAppSwitcherVC;
long long customSwitcherStyle = 2;
long long currentSwitcherStyle; 
BOOL appSwitcherOpen = FALSE;

//batteryView variables
NSUInteger connectedBluetoothDevicesCount;
NSArray *connectedBluetoothDevices;
NSMutableArray *connectedDevicesBaseViewArray;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];
int individualDeviceViewWidth = 50; 




void initBaseVaonView(UIView* view) {
	vaonViewBackgroundColor = [UIColor colorNamed:@"clearColor"];
	blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
	titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
	// view.frame = CGRectMake(500, 500, 500, 500);
	view.clipsToBounds = TRUE;
	view.layer.cornerRadius = vaonViewCornerRadius;
	view.alpha = 0;
	view.backgroundColor = vaonViewBackgroundColor;
	
	vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	vaonBlurView.frame = view.bounds;
	vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:vaonBlurView];

}


void initBatteryView(UIView *view){
	batteryHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
	batteryHStackView.axis = UILayoutConstraintAxisHorizontal;
	batteryHStackView.alignment = UIStackViewAlignmentCenter;
	batteryHStackView.distribution = UIStackViewDistributionFill;
	batteryHStackView.spacing = 30;
	batteryHStackView.clipsToBounds = TRUE;

	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
	connectedBluetoothDevicesCount = connectedBluetoothDevices.count;

	connectedDevicesBaseViewArray = [[NSMutableArray alloc] initWithCapacity:connectedBluetoothDevicesCount];


	batteryHStackView.translatesAutoresizingMaskIntoConstraints = false;
	
	[view addSubview:batteryHStackView];


	[batteryHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;

}



void fadeViewIn(UIView *view, CGFloat duration){
	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 1;
	} 
	completion:^(BOOL finished) {
		for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
			[subview animateOutlineLayer:1];
		}	
	}];	
}

void fadeViewOut(UIView *view, CGFloat duration){
	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 0;
	}
	completion:^(BOOL finished) {
		for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
			[subview resetStrokeEnd];
		}	
	}];	
}


void updateBattery() {

	dispatch_async(dispatch_get_main_queue(), ^{
		connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		NSMutableArray *subviewsToBeRemoved = [[NSMutableArray alloc] init];
		NSMutableArray *subviewsToBeAdded = [[NSMutableArray alloc] init];

		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
			[subview updateDevicePercentageLabel];
			[subview updateCircleOutline];
			// [subview.circleBackgroundVisualEffectView setNeedsDisplay];
			// [subview.circleOutlineLayer setNeedsDisplay];

			if(![connectedBluetoothDevices containsObject:subview.device]){

				[subviewsToBeRemoved addObject:subview];
			}
		}

		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *cell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
// ![deviceNames containsObject:device.name]
			if(![batteryHStackView.subviews containsObject:cell]&&![deviceNames containsObject:device.name]&&batteryHStackView.subviews.count<6){
				// VaonDeviceBatteryCell *cellToAdd = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device;
				[subviewsToBeAdded addObject:cell];
				[deviceNames addObject:cell.deviceName];
			}
		}

		for(VaonDeviceBatteryCell *subview in subviewsToBeAdded){
			// NSUInteger indexOfSubviewInHStack = [[batteryHStackView arrangedSubviews] indexOfObject:subview];
			// VaonDeviceBatteryCell *subviewToAdd = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:subview.device];

			[batteryHStackView addArrangedSubview:subview];

			subview.alpha = 0;
			[UIView animateWithDuration:0.3 animations:^ {
				subview.alpha = 1;

			}
			completion:^(BOOL finished) {
				[subviewsToBeAdded removeObject:subview];
			}];	
		}
		
		
		for(VaonDeviceBatteryCell *subview in subviewsToBeRemoved){
			//fade out subview and on completion remove it from arrangedSubview
			NSUInteger indexOfSubviewInHStack = [[batteryHStackView subviews] indexOfObject:subview];
			VaonDeviceBatteryCell *subviewToRemove = [[batteryHStackView subviews] objectAtIndex:indexOfSubviewInHStack];
			subviewToRemove.alpha = 1;
			[UIView animateWithDuration:0.3 animations:^ {
				subviewToRemove.alpha = 0;
			}
			completion:^(BOOL finished) {
					[batteryHStackView removeArrangedSubview:subview];
					[subviewsToBeRemoved removeObject:subview];
					[deviceNames removeObject:subview.deviceName];
			}];	
		}
		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
			if(![connectedBluetoothDevices containsObject:subview.device] || subview.device == nil){
				subview.alpha = 1;
				[UIView animateWithDuration:0.3 animations:^ {
					subview.alpha = 0;
				}
				completion:^(BOOL finished) {
					[subview removeFromSuperview];
					[batteryHStackView removeArrangedSubview:subview];
					[deviceNames removeObject:subview.deviceName];
			
				}];	
			}
		
		}


	

		
	}); 
}

%hook BCBatteryDevice

	-(void)setCharging: (BOOL)arg1 {
		updateBattery();
		%orig;
	}
	-(void)setBatterSaveModeActive:(BOOL)arg1 {
		// updateBattery();
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




%hook SBSwitcherAppSuggestionContentView

	//creates vaonview for normal/non-grid app switcher 
	-(void)didMoveToWindow {
		%orig;
		
		// UIInterfaceOrientation appSwitcherOrientation = [UIApplication sharedApplication].windows[0].windowScene.interfaceOrientation;
		deviceOrientation = [UIDevice currentDevice].orientation;
		CGFloat mainScreen = [[UIScreen mainScreen] bounds].size.height;

		if(!vaonViewIsInitialized){
			vaonView = [[UIView alloc] init];

			initBaseVaonView(vaonView);

			initBatteryView(vaonView);

			[self addSubview:vaonView];

			vaonView.translatesAutoresizingMaskIntoConstraints = false;
			[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = TRUE;
			[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
			[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
			[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = TRUE;


			vaonViewIsInitialized = TRUE;
		}
		//fades in the non-grid view when the app switcher is shown
		if(mainAppSwitcherVC.sbActiveInterfaceOrientation==1){
			// [UIView animateWithDuration:0.4 animations:^ {
			// 	vaonView.alpha = 1;
			// }];
			fadeViewIn(vaonView, 0.3);
		}

		
	}
%end

%hook SBMainSwitcherViewController


	-(void)viewDidLoad {
		%orig;
		mainAppSwitcherVC = self;
		dockWidth = mainAppSwitcherVC.view.frame.size.width*0.943;	
		
		//initializes vaon for grid mode 
		if(customSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
			if(!vaonViewIsInitialized){
				vaonGridView = [[UIView alloc] init];

				initBaseVaonView(vaonGridView);


				initBatteryView(vaonGridView);
				
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

	
	-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
		if (arg2 == FALSE) {
			// [UIView animateWithDuration:0.2 animations:^ {
			// 	vaonView.alpha = 0;
			// }];
			fadeViewOut(vaonView, 0.2);
		}
		%orig;
	}


	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {

		NSString *switcherTransitionRequest = [[NSString alloc] initWithFormat:@"%@", arg2];
		NSUInteger indexAfterAppLayout =  [switcherTransitionRequest rangeOfString: @"appLayout: "].location;
		NSString *appLayoutString = [switcherTransitionRequest substringFromIndex:indexAfterAppLayout];

		if(![appLayoutString containsString:@"appLayout: 0x0;"]){		
			// [UIView animateWithDuration:0.2 animations:^ {
			// 	vaonView.alpha = 0;
			// }];
			fadeViewOut(vaonView, 0.2);
		}
		%orig;
	}




	//fade in and out for vaon in grid mode
	-(void)_updateDisplayLayoutElementForLayoutState: (id)arg1 {
		%orig;
		appSwitcherOpen = [self isAnySwitcherVisible];
		if(customSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
			if(!appSwitcherOpen){
				// [UIView animateWithDuration:0.3 animations:^ {
				// 	vaonGridView.alpha = 0;
				// }];	
				fadeViewOut(vaonGridView, 0.3);

			}else{
				// [UIView animateWithDuration:0.3 animations:^ {
				// 	vaonGridView.alpha = 1;
				// }];	
				fadeViewIn(vaonGridView, 0.3);
			}
		}

	}


%end


%hook SBAppSwitcherSettings

	//Enable and customize grid mode 
	-(void)setSwitcherStyle: (long long)arg1 {
		currentSwitcherStyle = self.switcherStyle;
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
		self.hidden = TRUE;
	}
%end




void updateSettings(){
	[prefs registerBool:&isEnabled default:TRUE forKey:@"isEnabled"];

	[prefs registerObject:&switcherMode default:@"stock" forKey:@"switcherMode"];
}

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	updateSettings();

	if(isEnabled){
		%init;
	}

	if([switcherMode isEqual:@"grid"]){
		customSwitcherStyle = 2;
	}else{
		customSwitcherStyle = 1;
	}
}