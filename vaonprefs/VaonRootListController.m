#include "VaonRootListController.h"

@implementation VaonModuleSelectionController
	// - (NSArray *)specifiers {
	// 	if (!_specifiers) {
	// 		_specifiers = [self loadSpecifiersFromPlistName:@"ModuleSelection" target:self];
	// 	}

	// 	return _specifiers;
	// }

	// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// 		NSString *identifier = [[NSString alloc] initWithFormat:@"Module"];
	// 		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	// 		cell.textLabel.text = self.modules[indexPath.row];
	// 		cell.accessoryType = self.selectedIndexPath == indexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	// 		return cell;
	// }


	// -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// 	return 2;
	// }

	// - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	// 	return tableView.numberOfSections;
	// }


	// - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// 	if(indexPath.section==0){
    //     	[tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;
	// 		self.selectedIndexPath = indexPath;
	// 		[tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType = UITableViewCellAccessoryCheckmark;

	// 		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	// 	}
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

	// -(void)viewDidLoad {
	// 	[super viewDidLoad];
	// 	self.tableView.delegate = self;
	// 	self.tableView.dataSource = self;
	// 	self.title = @"Modules";
	// 	self.moduleTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

	// 	id modules[] = {@"Battery", @"None"};
	// 	self.count = sizeof(modules) / sizeof(id);
	// 	self.modules = [NSArray arrayWithObjects:modules count:self.count];

	// 	self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	// 	self.tableView = self.moduleTableView;
	// 	// [self.view addSubview:self.moduleTableView];
	// }
    

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
