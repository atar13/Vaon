//credit to https://github.com/vanwijkdave/QuitAll for help with adding the vaonView to the app switcher

//TODO: 
//raise the normal apps
//move vaonView to the bottom
//add customtext option to the top/bottom of vaon view

#import <Cephei/HBPreferences.h>

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;

@end

@interface SBSwitcherAppSuggestionContentView : UIView
@end


UIView *vaonView;
UIColor *vaonViewBackgroundColor;
UILabel *titleLabel;
BOOL vaonViewIsInitialized = FALSE;

%hook SBSwitcherAppSuggestionContentView

-(void)didMoveToWindow {
	%orig;
	if(!vaonViewIsInitialized){
		// vaonViewBackgroundColor = [[UIColor colorWithRed: 0.0/255.0
		// green: 0.0/255.0
		// blue: 255.0/255.0
		// alpha: 1.0] init];
		vaonViewBackgroundColor = [UIColor colorNamed:@"clearColor"];
		vaonView = [[UIView alloc] init];
		vaonView.frame = CGRectMake(500, 500, 500, 500);
		vaonView.clipsToBounds = TRUE;
		vaonView.layer.cornerRadius = 10;
		vaonView.alpha = 1;
		vaonView.backgroundColor = vaonViewBackgroundColor;



		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];

		UIVisualEffectView *vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		vaonBlurView.frame = vaonView.bounds;
		vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[vaonView addSubview:vaonBlurView];

		titleLabel = [[UILabel alloc] initWithFrame:vaonView.bounds];
		titleLabel.text = @"Xeris";
		CGFloat titleLabelFontSize = 15;
		UIFont *titleFont = [UIFont systemFontOfSize:titleLabelFontSize];
		titleLabel.font = titleFont;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.textColor = [UIColor whiteColor];

		[vaonView addSubview:titleLabel];

		titleLabel.translatesAutoresizingMaskIntoConstraints = false;
		[titleLabel.centerXAnchor constraintEqualToAnchor:vaonView.centerXAnchor].active = YES;
		[titleLabel.centerYAnchor constraintEqualToAnchor:vaonView.centerYAnchor].active = YES;


		[self addSubview:vaonView];
		vaonView.translatesAutoresizingMaskIntoConstraints = false;
		[vaonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:40].active = YES;
		[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
		[vaonView.widthAnchor constraintEqualToConstant:100].active = YES;
		[vaonView.heightAnchor constraintEqualToConstant:35].active = YES;



		vaonViewIsInitialized = TRUE;
	}
	[UIView animateWithDuration:0.3 animations:^ {
		vaonView.alpha = 1;
	}];
}
%end

%hook SBMainSwitcherViewController
	-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
		if (arg2 == FALSE) {
				[UIView animateWithDuration:0.3 animations:^ {
					vaonView.alpha = 0;
				}];
		}
		%orig;
	}

	// -(BOOL)_dismissSwitcherNoninteractivelyToAppLayout:(id)arg1 dismissFloatingSwitcher:(BOOL)arg2 animated:(BOOL)arg3 {
	// 	if(arg2 == FALSE){
	// 	HBLogWarn(@"VONC");
	// 	}
	// 	return %orig;
	// }

-(id)appLayoutsForSwitcherContentController:(id)arg1 {
	if(vaonView.alpha!=0){
		HBLogWarn(@"AXPER");
		[UIView animateWithDuration:0.3 animations:^ {
			vaonView.alpha = 0;
		}];
	}
	return %orig;
}


%end

