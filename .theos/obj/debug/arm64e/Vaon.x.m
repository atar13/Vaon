#line 1 "Vaon.x"

#import <Cephei/HBPreferences.h>

@interface SBMainSwitcherViewController : UIViewController
+ (id)sharedInstance;

@end

@interface SBSwitcherAppSuggestionContentView : UIView
@end


UIView *vaonView;
UIColor *vaonViewBackgroundColor;
BOOL vaonViewIsInitialized = FALSE;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBMainSwitcherViewController; @class SBSwitcherAppSuggestionContentView; 
static void (*_logos_orig$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow)(_LOGOS_SELF_TYPE_NORMAL SBSwitcherAppSuggestionContentView* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL SBSwitcherAppSuggestionContentView* _LOGOS_SELF_CONST, SEL); 

#line 17 "Vaon.x"


static void _logos_method$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL SBSwitcherAppSuggestionContentView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	_logos_orig$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow(self, _cmd);
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





static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBSwitcherAppSuggestionContentView = objc_getClass("SBSwitcherAppSuggestionContentView"); { MSHookMessageEx(_logos_class$_ungrouped$SBSwitcherAppSuggestionContentView, @selector(didMoveToWindow), (IMP)&_logos_method$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow, (IMP*)&_logos_orig$_ungrouped$SBSwitcherAppSuggestionContentView$didMoveToWindow);}} }
#line 48 "Vaon.x"
