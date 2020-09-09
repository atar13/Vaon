//credit to https://github.com/vanwijkdave/QuitAll for help with adding the vaonView to the app switcher

//TODO: 
//raise the normal apps
//move vaonView to the bottom
//add customtext option to the top/bottom of vaon view
//option for a split view of two widgets
//option ot have ipad style switcher
//check for landscape mode
//add option to remove handoff/suggested apps banner that interferes with vaon
//add option for vaon to fly up from the bottom	
//add option to ovveride landscape hide 
/**
recent  phone calls
favorite contacts
device batteries
favorited apps
music player
**/


#import <Cephei/HBPreferences.h>

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;
-(long long)sbActiveInterfaceOrientation;
@end

@interface SBSwitcherAppSuggestionContentView : UIView
@end

@interface SBFluidSwitcherItemContainer
// @property (nonatomic,retain) UIView* contentView;
@end

@interface SBAppSwitcherPageView : UIView 
@end

@interface SBDockView : UIView
+ (id)sharedInstance;
@property (nonatomic,readonly) CGRect dockListViewFrame;
@end

@interface SBFluidSwitcherViewController : UIViewController
@end

@interface SBDeckSwitcherViewController : SBFluidSwitcherViewController
@end

@interface SBFluidSwitcherTouchPassThroughScrollViewController : UIScrollView
- (id)view;
@end 

@interface SBFView : UIView
@end

@interface SBAppSwitcherPageShadowView :SBFView 
@end

@interface SBFluidSwitcherContentView : UIView
@end



UIView *vaonView;
UIColor *vaonViewBackgroundColor;
UILabel *titleLabel;
// UIView *appSwitcherView;
CGFloat dockWidth;
BOOL vaonViewIsInitialized = FALSE;
UIDeviceOrientation deviceOrientation;
NSLayoutYAxisAnchor *appSwitcherBottomAnchor;
long long sbAppSwitcherOrientation;
SBMainSwitcherViewController *mainAppSwitcherVC;

%hook SBSwitcherAppSuggestionContentView

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
			CGFloat titleLabelFontSize = 22;
			UIFont *titleFont = [UIFont systemFontOfSize:titleLabelFontSize];
			titleLabel.font = titleFont;
			titleLabel.textAlignment = NSTextAlignmentLeft;
			titleLabel.textColor = [UIColor whiteColor];

			[vaonView addSubview:titleLabel];

			titleLabel.translatesAutoresizingMaskIntoConstraints = false;
			[titleLabel.centerXAnchor constraintEqualToAnchor:vaonView.centerXAnchor].active = YES;
			[titleLabel.centerYAnchor constraintEqualToAnchor:vaonView.centerYAnchor].active = YES;

			[self addSubview:vaonView];

			vaonView.translatesAutoresizingMaskIntoConstraints = false;
			[vaonView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-23].active = YES;
			[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
			[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = YES;
			[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = YES;


			vaonViewIsInitialized = TRUE;
		}

		if(mainAppSwitcherVC.sbActiveInterfaceOrientation==1){
		// if(UIDeviceOrientationIsPortrait(deviceOrientation)){
			[UIView animateWithDuration:0.4 animations:^ {
				vaonView.alpha = 1;
			}];
		// }
		}
		
	}
%end

%hook SBMainSwitcherViewController

	-(void)viewDidLoad {
		%orig;
		mainAppSwitcherVC = self;
		// appSwitcherView =  self.view;
		dockWidth = mainAppSwitcherVC.view.frame.size.width*0.943;	
		// appSwitcherBottomAnchor = self.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].bottomAnchor;
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
		[UIView animateWithDuration:0.2 animations:^ {
			vaonView.alpha = 0;
		}];
		%orig;
	}

// -(id)appLayoutsForSwitcherContentController:(id)arg1 {
// 	if(vaonView.alpha!=0){
// 		[UIView animateWithDuration:0.3 animations:^ {
// 			// vaonView.alpha = 0;
// 		}];
// 	}
// 	return %orig;
// }

%end

%hook SBFluidSwitcherViewController

	// -(void)shouldAddAppLayoutToFront: (id)arg1 forTransitionWithContext:(id)arg2 transitionCompleted:(BOOL)arg3{
	// 	%orig;
	// 	[UIView animateWithDuration:0.1 animations:^ {
	// 		vaonView.alpha = 0;
	// 	}];
		
	// }

%end


%hook SBDeckSwitcherViewController
	-(void)viewDidLoad {
		%orig;

		// appSwitcherBottomAnchor = self.viewIfLoaded.subviews[1].subviews[0].bottomAnchor;
		// [vaonView.topAnchor constraintEqualToAnchor:appSwitcherBottomAnchor].active = YES;

	}


%end

%hook SBFluidSwitcherTouchPassThroughScrollViewController
	-(void)viewDidLoad {
		%orig;
		// [vaonView.topAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:20].active = YES;
	}
%end


