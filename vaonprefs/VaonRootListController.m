#include "VaonRootListController.h"

//maybe check if the user is going back to the previous value a specifier was at before prompting the alert to repsring
//make a new NSUserDefauls
NSUserDefaults *prefs;
NSArray *rootPreferenceKeys;
NSArray *batteryPreferenceKeys;

//Function to check if an alias exists at a path
BOOL aliasExistsAtPath(NSString *path) {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    BOOL isAlias = [url checkResourceIsReachableAndReturnError:&error];
    
    if (isAlias) {
        return YES;
    } else if (!isAlias && error.code == NSFileReadNoSuchFileError) {
        return NO;
    } else {
        NSLog(@"Error: %@", error);
        return NO;
    }
}

@implementation BatteryColorPreferenceController

	// -(id)init {
	// 	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	// 	return [super init];
	// }

	-(NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [self loadSpecifiersFromPlistName:@"BatteryColor" target:self];
		}

		return _specifiers;
	}
	-(void)viewDidLoad {
		[super viewDidLoad];
		self.title = @"Battery Color Settings";
	}
	-(void)respring {
		pid_t pid;
		const char* args[] = {"killall", "-9", "backboardd", NULL};
		if (aliasExistsAtPath(@"/var/jb")){
			posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		} else{
			posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		}
	}

	-(void)askBeforeRespring {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to respring?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
	}

    -(void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(askBeforeRespring)];
        self.navigationItem.rightBarButtonItem = respringButton; 
    }
	-(void)prefsChangeAlert {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring is required" message:@"To apply this change you must respring your device" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
	}

	// -(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{
	// 	[super setPreferenceValue:value specifier:specifier];
	// 	if((BOOL)specifier.properties[@"value"]==[prefs boolForKey:specifier.properties[@"key"]]){
	// 		if([batteryPreferenceKeys containsObject:specifier.properties[@"key"]]){
	// 			// [self prefsChangeAlert];
	// 		}
	// 	}
	// }


    

@end


@implementation BatteryPreferenceController

	// -(id)init {
	// 	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	// 	return [super init];
	// }

	-(NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [self loadSpecifiersFromPlistName:@"Battery" target:self];
		}

		return _specifiers;
	}
	-(void)viewDidLoad {
		[super viewDidLoad];
		self.title = @"Battery Settings";
	}
	-(void)respring {
		pid_t pid;
		const char* args[] = {"killall", "-9", "backboardd", NULL};
		if (aliasExistsAtPath(@"/var/jb")){
			posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		} else{
			posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		}
	}

	-(void)askBeforeRespring {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to respring?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
	}

    -(void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(askBeforeRespring)];
        self.navigationItem.rightBarButtonItem = respringButton; 
    }
	-(void)prefsChangeAlert {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring is required" message:@"To apply this change you must respring your device" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
	}

	-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{
		[super setPreferenceValue:value specifier:specifier];
		if((BOOL)specifier.properties[@"value"]==[[prefs objectForKey:specifier.properties[@"key"]] boolValue]){
			if([batteryPreferenceKeys containsObject:specifier.properties[@"key"]]){
				// [self prefsChangeAlert];
			}
		}
	}


    

@end

@implementation VaonRootListController
	//-(id)readPreferenceValue:(PSSpecifier*)specifier; use this to get the current modele selected and make a method that returns it and passes it into the pslinkcell in root.plist
	-(id)init {
		prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.atar13.vaonprefs"];
		rootPreferenceKeys = @[
			@"isEnabled", 
			@"switcherMode", 
			@"moduleSelection", 
			@"hideBackground",
			@"hideAppTitles",
			@"hideAppIcons",
			@"hideSuggestionBanner", 
			@"enableFlyInOut",
			@"enableDelay",
			@"customHeightEnabled", 
			@"customWidthEnabled", 
			@"customVerticalOffsetEnabled",
			@"customGridSwitcherAppSizeEnabled",
			@"customGridSwitcherSpacingEnabled"
		];
		batteryPreferenceKeys = @[
			@"hideInternal", 
			@"hidePercent", 
			@"enableBoldPercentage",
			@"roundOutlineCorners", 
			@"pulsateChargingOutline", 
			@"customBatteryCellSizeEnabled", 
			@"customPercentageFontSizeEnabled",
			@"roundOutlineCorners", 
			@"keepDisconnectedDevices"
		];
		return [super init];
	}

	-(NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		}

		return _specifiers;
	}

	-(void)respring {
		pid_t pid;
		const char* args[] = {"killall", "-9", "backboardd", NULL};
		if (aliasExistsAtPath(@"/var/jb")){
			posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		} else{
			posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		}
	}
	-(void)askBeforeRespring {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to respring?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			[self respring];
		}];
		UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		[alert addAction:respringAction];
		[alert addAction:laterAction];
		[self presentViewController:alert animated:YES completion:nil];
	}

	//methods for links to social media/github
	-(void)reddit {
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"https://reddit.com/u/atar13"] 
			options:@{} 
		completionHandler:nil];
	}

	- (void)twitter {
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"https://twitter.com/atar137h"] 
			options:@{} 
		completionHandler:nil];
	}

	- (void)twitterKeycap {
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"https://twitter.com/singlekeycap"] 
			options:@{} 
		completionHandler:nil];
	}

	-(void)email{
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"mailto:atar13dev@gmail.com"] 
			options:@{} 
		completionHandler:nil];
	}

	-(void)github{
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"https://github.com/atar13/Vaon"] 
			options:@{} 
		completionHandler:nil];
	}

	-(void)report{
		[[UIApplication sharedApplication] 
			openURL:[NSURL URLWithString:@"https://github.com/atar13/Vaon/issues/new"] 
			options:@{} 
		completionHandler:nil];
	}

	- (void)viewWillAppear:(BOOL)animated {
		[super viewWillAppear:animated];
		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(askBeforeRespring)];
		self.navigationItem.rightBarButtonItem = respringButton; 
	}

	-(void)prefsChangeAlert {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring is required" message:@"To apply this change you must respring your device" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
	}
	-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{
		[super setPreferenceValue:value specifier:specifier];
		if([rootPreferenceKeys containsObject:specifier.properties[@"key"]]){

			if([specifier.properties[@"cell"] isEqual:@"PSSwitchCell"]){
				if(!(BOOL)specifier.properties[@"value"]==[[prefs objectForKey:specifier.properties[@"key"]] boolValue]){
						// [self prefsChangeAlert];
				}
			}
			else {
				[self prefsChangeAlert];
			}
		}
	}



@end


@implementation ImageCell

	-(id)initWithSpecifier:(PSSpecifier *)specifier {
		self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
		if(self){
		CGRect frame = CGRectMake(0, 2, [[UIScreen mainScreen] bounds].size.width, 60);

        NSString *customImagePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/VaonPrefs.bundle/images/email/emailIcon@3x.png"];
		image = [[UIImage alloc] initWithContentsOfFile:customImagePath];
		if(image == nil){
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			NSString *labelText = @"Image didn't load";
			label.text = labelText;
			[self addSubview:label];
		} else {
			imageView = [[UIImageView alloc] initWithImage:image];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			
			[self addSubview:imageView];
		}
		}
		return self;
	}

	- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	// Return a custom cell height.
		return 100.f;
	}
@end