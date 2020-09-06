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
BOOL vaonViewIsInitialized = FALSE;

%hook SBSwitcherAppSuggestionContentView

-(void)didMoveToWindow {
	%orig;
	if(!vaonViewIsInitialized){
		vaonViewBackgroundColor = [[UIColor colorWithRed: 0.0/255.0
		green: 0.0/255.0
		blue: 255.0/255.0
		alpha: 1.0] init];
		vaonView = [[UIView alloc] init];
		vaonView.frame = CGRectMake(500, 500, 500, 500);
		vaonView.clipsToBounds = TRUE;
		vaonView.layer.cornerRadius = 10;
		vaonView.alpha = 1;
		vaonView.backgroundColor = vaonViewBackgroundColor;

		[self addSubview:vaonView];
		vaonView.translatesAutoresizingMaskIntoConstraints = false;
		[vaonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:50].active = YES;
		[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
		[vaonView.widthAnchor constraintEqualToConstant:100].active = YES;
		[vaonView.heightAnchor constraintEqualToConstant:50].active = YES;

		vaonViewIsInitialized = TRUE;
	}
}
%end

%hook SBMainSwitcherViewController

%end