#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>   

@interface VaonRootListController : PSListController
@end

@interface BatteryPreferenceController : PSListController
@end

@interface BatteryColorPreferenceController : PSListController
@end

@protocol PreferencesTableImageView
-(id)initWithSpecifier:(PSSpecifier *)specifier;
-(CGFloat)preferredHeightForWidth:(CGFloat)width;
@end 

@interface ImageCell : PSTableCell <PreferencesTableImageView> {
    UIImageView *imageView;
    UIImage *image;
}
@end

