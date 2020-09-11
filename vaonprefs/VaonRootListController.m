#include "VaonRootListController.h"

#import <spawn.h>

@implementation VaonRootListController

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
	UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	self.navigationItem.rightBarButtonItem = respringButton; 
}

@end
