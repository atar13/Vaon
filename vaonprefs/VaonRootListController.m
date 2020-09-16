#include "VaonRootListController.h"

@implementation VaonModuleSelectionController
	- (NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [self loadSpecifiersFromPlistName:@"ModuleSelection" target:self];
		}

		return _specifiers;
	}
    // -(void)viewDidLoad {
    //     [super viewDidLoad];
	// 	self.navigationItem.title = @"Select Module";
   	//  	self.modules = [[NSArray alloc] initWithObjects:@"Battery",@"None",nil];

    //     self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	// 	self.tableView.delegate = self;
	// 	self.tableView.dataSource = self;

	// 	[self.view addSubview:self.tableView];

    // }

  	// // -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// // 	  return 1;
	// //   }
	// -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// 	return self.modules.count;
	// }
	// -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// 	static NSString *cellIdentifier = @"moduleCell";
	// 	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	// 	if(cell == nil) {
    //     	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    // 	}
	// 	cell.textLabel.text = [self.modules objectAtIndex:indexPath.row];
	// 	return cell;
	// }
	// -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// 	// HBLogWarn(@"%@",[self.modules objectAtIndex:indexPath.row]);
	// }
	-(void)respring {
		pid_t pid;
		const char* args[] = {"killall", "-9", "backboardd", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	}

    -(void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
        self.navigationItem.rightBarButtonItem = respringButton; 
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
