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
/**
recent  phone calls
favorite contacts
device batteries
favorited apps
music player
countdown 
airpod pro transparency and noise cancellation
**/

//credit to Dogbert for the icon


#import <Cephei/HBPreferences.h>
#import <Vaon.h>


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
int individualDeviceViewWidth = 50; 

CGFloat degreesToRadians(CGFloat degrees){
	return degrees*(M_PI/180);
}

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

void reloadBatteryInfo(){
	for(int i = 0; i<connectedBluetoothDevicesCount; i++){
		if(i<=6){
			BCBatteryDevice *device = connectedBluetoothDevices[i];
			UIStackView *connectedDeviceBaseView = [[UIStackView alloc] init];
			connectedDeviceBaseView.axis = UILayoutConstraintAxisVertical;
			connectedDeviceBaseView.alignment = UIStackViewAlignmentCenter;
			connectedDeviceBaseView.distribution = UIStackViewDistributionFill;
			connectedDeviceBaseView.spacing = 10;
			connectedDeviceBaseView.clipsToBounds = TRUE;
			connectedDeviceBaseView.backgroundColor = [UIColor clearColor];
			connectedDeviceBaseView.frame = batteryHStackView.bounds;

			UIView *devicePercentChargeBackgroundCircleView = [[UIView alloc] init];
			devicePercentChargeBackgroundCircleView.frame = connectedDeviceBaseView.bounds;
			devicePercentChargeBackgroundCircleView.backgroundColor = [UIColor clearColor];
			devicePercentChargeBackgroundCircleView.layer.cornerRadius = individualDeviceViewWidth/2;

			UILabel *deviceNameLabel = [[UILabel alloc] init];
			NSMutableString *devicePercentCharge = [NSMutableString stringWithFormat: @"%lld", [device percentCharge]];
			[devicePercentCharge appendString:@"%"];
			deviceNameLabel.text = devicePercentCharge;
			// deviceNameLabel.adjustsFontSizeToFitWidth = TRUE;
			UIFont *deviceNameLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
			deviceNameLabel.font = deviceNameLabelFont;
			deviceNameLabel.frame = devicePercentChargeBackgroundCircleView.bounds;
			deviceNameLabel.clipsToBounds = TRUE;


			UIBlurEffect *devicePercentChargeBackgroundCircleViewBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
			UIVisualEffectView *devicePercentChargeBackgroundCircleViewVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:devicePercentChargeBackgroundCircleViewBlurEffect];
			// devicePercentChargeBackgroundCircleViewVisualEffectView.frame = devicePercentChargeBackgroundCircleView.bounds;
			devicePercentChargeBackgroundCircleViewVisualEffectView.layer.cornerRadius = individualDeviceViewWidth/2;
			devicePercentChargeBackgroundCircleViewVisualEffectView.clipsToBounds = TRUE;
			devicePercentChargeBackgroundCircleViewVisualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

			[devicePercentChargeBackgroundCircleView addSubview:devicePercentChargeBackgroundCircleViewVisualEffectView];
	
			[devicePercentChargeBackgroundCircleView addSubview:deviceNameLabel];

			devicePercentChargeBackgroundCircleView.translatesAutoresizingMaskIntoConstraints = FALSE;
			[devicePercentChargeBackgroundCircleView.widthAnchor constraintEqualToConstant:individualDeviceViewWidth].active = TRUE;
			[devicePercentChargeBackgroundCircleView.heightAnchor constraintEqualToConstant:individualDeviceViewWidth].active = TRUE;
			[connectedDeviceBaseView addArrangedSubview:devicePercentChargeBackgroundCircleView];

			deviceNameLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
			[deviceNameLabel.centerXAnchor constraintEqualToAnchor:devicePercentChargeBackgroundCircleView.centerXAnchor].active = TRUE;
			[deviceNameLabel.centerYAnchor constraintEqualToAnchor:devicePercentChargeBackgroundCircleView.centerYAnchor].active = TRUE;




			UIBezierPath *devicePercentChargeBackgroundCircleViewOutlinePath = [UIBezierPath bezierPath];
			[devicePercentChargeBackgroundCircleViewOutlinePath addArcWithCenter:CGPointMake(devicePercentChargeBackgroundCircleView.center.x+individualDeviceViewWidth/2,devicePercentChargeBackgroundCircleView.center.y+individualDeviceViewWidth/2) 
				radius:individualDeviceViewWidth/2
				startAngle:degreesToRadians(-90) 
				endAngle:degreesToRadians((3.6*[device percentCharge])-90) 
				clockwise:TRUE];
			// devicePercentChargeBackgroundCircleViewOutlinePath.lineWidth = 5;

			CAShapeLayer *circleOutlineLayer = [[CAShapeLayer alloc] init];
			circleOutlineLayer.bounds = devicePercentChargeBackgroundCircleView.bounds;
			circleOutlineLayer.position = devicePercentChargeBackgroundCircleView.center;
			circleOutlineLayer.fillColor = [UIColor clearColor].CGColor;
			circleOutlineLayer.strokeColor = [UIColor greenColor].CGColor;
			circleOutlineLayer.path = devicePercentChargeBackgroundCircleViewOutlinePath.CGPath;
			circleOutlineLayer.lineWidth = individualDeviceViewWidth/10;
			// [devicePercentChargeBackgroundCircleViewOutlinePath fill];
			[devicePercentChargeBackgroundCircleView.layer addSublayer:circleOutlineLayer];


			UIImageView *deviceGlyphView = [[UIImageView alloc] initWithImage:device.glyph];
			[connectedDeviceBaseView addArrangedSubview:deviceGlyphView];

			connectedDevicesBaseViewArray[i] = connectedDeviceBaseView;
			[batteryHStackView addArrangedSubview:connectedDeviceBaseView];
			
		}
	}	
}

void initBatteryView(UIView *view){
	batteryHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
	batteryHStackView.axis = UILayoutConstraintAxisHorizontal;
	batteryHStackView.alignment = UIStackViewAlignmentCenter;
	batteryHStackView.distribution = UIStackViewDistributionFill;
	batteryHStackView.spacing = 35;
	batteryHStackView.clipsToBounds = TRUE;

	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
	connectedBluetoothDevicesCount = connectedBluetoothDevices.count;

	connectedDevicesBaseViewArray = [[NSMutableArray alloc] initWithCapacity:connectedBluetoothDevicesCount];


	reloadBatteryInfo();


	batteryHStackView.translatesAutoresizingMaskIntoConstraints = false;

	[view addSubview:batteryHStackView];

	[batteryHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;

}



void fadeViewIn(UIView *view){

}
void fadeViewOut(UIView *view){

}

void animateBatteryCircle() {

}

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
			[UIView animateWithDuration:0.4 animations:^ {
				vaonView.alpha = 1;
			}];
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
			[UIView animateWithDuration:0.2 animations:^ {
				vaonView.alpha = 0;
			}];
		}
		%orig;
	}


	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {

		NSString *switcherTransitionRequest = [[NSString alloc] initWithFormat:@"%@", arg2];
		NSUInteger indexAfterAppLayout =  [switcherTransitionRequest rangeOfString: @"appLayout: "].location;
		NSString *appLayoutString = [switcherTransitionRequest substringFromIndex:indexAfterAppLayout];

		if(![appLayoutString containsString:@"appLayout: 0x0;"]){		
			[UIView animateWithDuration:0.2 animations:^ {
				vaonView.alpha = 0;
			}];
		}
		%orig;
	}




	//fade in and out for vaon in grid mode
	-(void)_updateDisplayLayoutElementForLayoutState: (id)arg1 {
		%orig;
		appSwitcherOpen = [self isAnySwitcherVisible];
		if(customSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
			if(!appSwitcherOpen){
				[UIView animateWithDuration:0.3 animations:^ {
					vaonGridView.alpha = 0;
				}];	

			}else{
				[UIView animateWithDuration:0.3 animations:^ {
					vaonGridView.alpha = 1;
				}];	
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



%hook SBFluidSwitcherContentView
	-(void)didMoveToWindow {
		%orig;
	// 	if(!vaonViewIsInitialized){
	// 		if(switcherStyle==2){
	// 		// deviceOrientation = [UIDevice currentDevice].orientation;
	// 		// CGFloat mainScreen = [[UIScreen mainScreen] bounds].size.height;
	// 		UIColor *vaonGridViewBackgroundColor = [UIColor colorNamed:@"clearcolor"];
	// 		vaonGridView = [[UIView alloc] init];
	// 		vaonGridView.frame = CGRectMake(500, 500, 500, 500);
	// 		vaonGridView.clipsToBounds = TRUE;
	// 		vaonGridView.layer.cornerRadius = 15;
	// 		vaonGridView.alpha = 1;
	// 		vaonGridView.backgroundColor = vaonGridViewBackgroundColor;

	// 		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];

	// 		UIVisualEffectView *vaonGridBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	// 		vaonGridBlurView.frame = vaonGridView.bounds;
	// 		vaonGridBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	// 		[vaonGridView addSubview:vaonGridBlurView];

	// 		UILabel *vaonGridTitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
	// 		vaonGridTitleLabel.text = @"Vaon";
	// 		CGFloat titleLabelFontSize = 15;
	// 		UIFont *vaonGridTitleFont = [UIFont systemFontOfSize:titleLabelFontSize];
	// 		vaonGridTitleLabel.font = vaonGridTitleFont;
	// 		vaonGridTitleLabel.textAlignment = NSTextAlignmentLeft;
	// 		vaonGridTitleLabel.textColor = [UIColor whiteColor];

	// 		[vaonGridView addSubview:vaonGridTitleLabel];

	// 		vaonGridTitleLabel.translatesAutoresizingMaskIntoConstraints = false;
	// 		[vaonGridTitleLabel.topAnchor constraintEqualToAnchor:vaonGridView.topAnchor constant:10].active = TRUE;
	// 		[vaonGridTitleLabel.leftAnchor constraintEqualToAnchor:vaonGridView.leftAnchor constant:10].active = TRUE;

	// 		[self addSubview:vaonGridView];

	// 		vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
	// 		[vaonGridView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = TRUE;
	// 		[vaonGridView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
	// 		[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
	// 		[vaonGridView.heightAnchor constraintEqualToConstant:113].active = TRUE;

	// 		vaonViewIsInitialized = TRUE;
	// 	}
	// 	}
	// 	// [UIView animateWithDuration:0.4 animations:^ {
	// 	// 	vaonGridView.alpha = 1;
	// 	// }];
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