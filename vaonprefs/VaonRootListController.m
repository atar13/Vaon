#include "VaonRootListController.h"

//maybe check if the user is going back to the previous value a speciefier was at before prompting the alert to repsring
//make a new HBPrefs

@implementation BatteryPreferencesController
	- (NSArray *)specifiers {
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
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
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

	-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{
		[super setPreferenceValue:value specifier:specifier];
		if([specifier.properties[@"key"] isEqualToString:@"hideInternal"]){
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring is required" message:@"To apply this change you must respring your device" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
				[self respring];
			}];
			UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
			[alert addAction:respringAction];
			[alert addAction:laterAction];
			[self presentViewController:alert animated:YES completion:nil];
		}
	}


    

@end

@implementation VaonRootListController
	//-(id)readPreferenceValue:(PSSpecifier*)specifier; use this to get the current modele selected and make a method that returns it and passes it into the pslinkcell in root.plist


	- (NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		}

		return _specifiers;
	}

	-(void)respring {
		pid_t pid;
		const char* args[] = {"killall", "-9", "backboardd", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
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

	- (void)viewWillAppear:(BOOL)animated {
		[super viewWillAppear:animated];
		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(askBeforeRespring)];
		self.navigationItem.rightBarButtonItem = respringButton; 
	}

	-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{

			[super setPreferenceValue:value specifier:specifier];
			
			if([specifier.properties[@"key"] isEqualToString:@"isEnabled"]||
				[specifier.properties[@"key"] isEqualToString:@"switcherMode"]||
				[specifier.properties[@"key"] isEqualToString:@"moduleSelection"]||
				[specifier.properties[@"key"] isEqualToString:@"hideSuggestionBanner"]){
				UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring is required" message:@"To apply this change you must respring your device" preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
					[self respring];
				}];
				UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
				[alert addAction:respringAction];
				[alert addAction:laterAction];
				[self presentViewController:alert animated:YES completion:nil];
			}
	}

@end
