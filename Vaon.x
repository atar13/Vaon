//TODO: 
//raise the normal apps
//move vaonView to the bottom
//add customtext option to the top/bottom of vaon view
//option for a split view of two widgets
//option to have ipad style switcher : DONE
//check for landscape mode : DONE
//add option to remove handoff/suggested apps banner that interferes with vaon
//add option for vaon to fly up from the bottom	
//add option to ovveride landscape hide 
//hide appname/icon from sbappswitchersettings
//options for custom placement and resizing
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
UIColor *vaonViewBackgroundColor;
UILabel *titleLabel;

CGFloat dockWidth;
BOOL vaonViewIsInitialized = FALSE;

UIDeviceOrientation deviceOrientation;
// long long sbAppSwitcherOrientation;
SBMainSwitcherViewController *mainAppSwitcherVC;
long long customSwitcherStyle = 2;
long long currentSwitcherStyle; 
BOOL appSwitcherOpen = FALSE;

UIView *vaonGridView;


void initBaseVaonView() {

}


%hook SBSwitcherAppSuggestionContentView

	//creates vaonview for normal/non-grid app switcher 
	-(void)didMoveToWindow {
		%orig;

		// UIInterfaceOrientation appSwitcherOrientation = [UIApplication sharedApplication].windows[0].windowScene.interfaceOrientation;
		deviceOrientation = [UIDevice currentDevice].orientation;
		CGFloat mainScreen = [[UIScreen mainScreen] bounds].size.height;

		if(!vaonViewIsInitialized){
			// vaonViewBackgroundColor = [[UIColor colorWithRed: 0.0/255.0
			// green: 0.0/255.0
			// blue: 255.0/255.0
			// alpha: 1.0] init];
			vaonViewBackgroundColor = [UIColor colorNamed:@"clearColor"];
			vaonView = [[UIView alloc] init];
			vaonView.frame = CGRectMake(500, 500, 500, 500);
			vaonView.clipsToBounds = TRUE;
			vaonView.layer.cornerRadius = 15;
			vaonView.alpha = 0;
			vaonView.backgroundColor = vaonViewBackgroundColor;



			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];

			UIVisualEffectView *vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
			vaonBlurView.frame = vaonView.bounds;
			vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[vaonView addSubview:vaonBlurView];

			titleLabel = [[UILabel alloc] initWithFrame:vaonView.bounds];
			titleLabel.text = @"Vaon";
			CGFloat titleLabelFontSize = 15;
			UIFont *titleFont = [UIFont systemFontOfSize:titleLabelFontSize];
			titleLabel.font = titleFont;
			titleLabel.textAlignment = NSTextAlignmentLeft;
			titleLabel.textColor = [UIColor whiteColor];

			[vaonView addSubview:titleLabel];

			titleLabel.translatesAutoresizingMaskIntoConstraints = false;
			[titleLabel.topAnchor constraintEqualToAnchor:vaonView.topAnchor constant:5].active = YES;
			[titleLabel.leftAnchor constraintEqualToAnchor:vaonView.leftAnchor constant:10].active = YES;

			[self addSubview:vaonView];

			vaonView.translatesAutoresizingMaskIntoConstraints = false;
			[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = YES;
			[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
			[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = YES;
			[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = YES;


			vaonViewIsInitialized = TRUE;
		}

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
		if(customSwitcherStyle==2){
			if(!vaonViewIsInitialized){
				UIColor *vaonGridViewBackgroundColor = [UIColor colorNamed:@"clearcolor"];
				vaonGridView = [[UIView alloc] init];
				vaonGridView.frame = CGRectMake(500, 500, 500, 500);
				vaonGridView.clipsToBounds = TRUE;
				vaonGridView.layer.cornerRadius = 15;
				vaonGridView.alpha = 0;
				vaonGridView.backgroundColor = vaonGridViewBackgroundColor;

				UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];

				UIVisualEffectView *vaonGridBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
				vaonGridBlurView.frame = vaonGridView.bounds;
				vaonGridBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				[vaonGridView addSubview:vaonGridBlurView];

				UILabel *vaonGridTitleLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
				vaonGridTitleLabel.text = @"Vaon";
				CGFloat titleLabelFontSize = 15;
				UIFont *vaonGridTitleFont = [UIFont systemFontOfSize:titleLabelFontSize];
				vaonGridTitleLabel.font = vaonGridTitleFont;
				vaonGridTitleLabel.textAlignment = NSTextAlignmentLeft;
				vaonGridTitleLabel.textColor = [UIColor whiteColor];

				[vaonGridView addSubview:vaonGridTitleLabel];

				vaonGridTitleLabel.translatesAutoresizingMaskIntoConstraints = false;
				[vaonGridTitleLabel.topAnchor constraintEqualToAnchor:vaonGridView.topAnchor constant:10].active = YES;
				[vaonGridTitleLabel.leftAnchor constraintEqualToAnchor:vaonGridView.leftAnchor constant:10].active = YES;

				[self.view addSubview:vaonGridView];

				vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
				[vaonGridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-23].active = YES;
				[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
				[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = YES;
				[vaonGridView.heightAnchor constraintEqualToConstant:113].active = YES;

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
		if(customSwitcherStyle==2){
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


%hook SBGridSwitcherViewController
	-(void)viewDidLoad {
		%orig;

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
	// 		[vaonGridTitleLabel.topAnchor constraintEqualToAnchor:vaonGridView.topAnchor constant:10].active = YES;
	// 		[vaonGridTitleLabel.leftAnchor constraintEqualToAnchor:vaonGridView.leftAnchor constant:10].active = YES;

	// 		[self addSubview:vaonGridView];

	// 		vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
	// 		[vaonGridView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = YES;
	// 		[vaonGridView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
	// 		[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = YES;
	// 		[vaonGridView.heightAnchor constraintEqualToConstant:113].active = YES;

	// 		vaonViewIsInitialized = TRUE;
	// 	}
	// 	}
	// 	// [UIView animateWithDuration:0.4 animations:^ {
	// 	// 	vaonGridView.alpha = 1;
	// 	// }];
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