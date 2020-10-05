//TODO: 
//option to keep old disconnected devices on the view
//custom colors for different battery modes
//add customtext option to the top/bottom of vaon view
//option for a split view of two widgets
//add option for vaon to fly up from the bottom	
//options for custom placement and resizing
//make social media icons filled and grey/colorful
//option to hide percent character
//change color of outline depending on percentage
//raise app switcher
/**
favorite contacts or an option for recents
device batteries
favorited apps
music player when you 
countdown 
airpod pro transparency and noise cancellation
weather/AQI view that's similar to battery view
**/

//credit to Dogbert for the icon
#import "Vaon.h"

@implementation StrokeEndAnimationDelegate 

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell {
		self = [super init];
		self.cell = cell;
		return self;
	}
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag){
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue
							forKey:kCATransactionDisableActions];
			self.cell.circleOutlineLayer.strokeEnd = [self.cell devicePercentageAsProgress];
			[CATransaction commit];
			if(pulsateChargingOutline){
				[self.cell pulsateOutline];
			}
		}
	}

@end

@implementation PulsateColorAnimationDelegate

	-(instancetype)initWithCell:(VaonDeviceBatteryCell *)cell nextAnimation:(CAAnimation *)nextAnimation {
		self = [super init];
		self.cell = cell;
		self.nextAnimation = nextAnimation;
		return self;
	}
    -(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
		if(flag&&[self.cell.device isCharging]&&pulsateChargingOutline){
			self.cell.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
			[self.cell updateOutlineColor];
			if([self.cell.device isCharging]){
				[self.cell.circleOutlineLayer addAnimation:self.nextAnimation forKey:kCATransition];
			}			

		}
	}

@end

@implementation VaonDeviceBatteryCell
	UIColor *lowPowerModeColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
	// UIColor *normalBatteryColor = [UIColor colorWithRed:0.1882352941 green:0.8196078431 blue:0.3450980392 alpha: 1];
	UIColor *lowBatteryColor = [UIColor redColor];
	UIColor *brightGreen = [UIColor colorWithRed:0.1746478873 green:0.2039215686 blue:0.1960784314 alpha: 1];

    -(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)connectedDevice {
        self.device = connectedDevice;
		self.disconnected = FALSE;
		if(customBatteryCellSizeEnabled){
        	self.cellWidth = CGFloat(customBatteryCellSize);
		} else {
			self.cellWidth = CGFloat(50);
		}
        self.devicePercentage = [connectedDevice percentCharge];

        self = [super initWithFrame:arg1];
        self.axis = UILayoutConstraintAxisVertical;
        self.alignment = UIStackViewAlignmentCenter;
        self.distribution = UIStackViewDistributionEqualSpacing;
        self.spacing = 10;
        self.clipsToBounds = FALSE;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = FALSE;
    
		self.circleBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        self.circleBackgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:self.circleBackgroundBlurEffect];
        self.circleBackgroundVisualEffectView.layer.cornerRadius = self.cellWidth/2;
        self.circleBackgroundVisualEffectView.clipsToBounds = TRUE;
        self.circleBackgroundVisualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.circleBackgroundVisualEffectView.frame = self.bounds;
       	self.circleBackgroundVisualEffectView.contentMode = UIViewContentModeScaleAspectFill;


        self.devicePercentageLabel = [[UILabel alloc] init];
        // self.devicePercentageString = [NSMutableString stringWithFormat: @"%lld", [self devicePercentage]]; 
        // self.devicePercentageLabel.text =;
        [self updateDevicePercentageLabel];
        [self addPercentageSymbolToLabel];
        // self.devicePercentageLabel.numberOfLines = 1;
		UIFont *devicePercentageLabelFont = [[UIFont alloc] init];
		if(customPercentageFontSizeEnabled){
        	devicePercentageLabelFont = [UIFont systemFontOfSize:customPercentageFontSize weight:UIFontWeightBold];
		} else{
        	devicePercentageLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
		}
        self.devicePercentageLabel.font = devicePercentageLabelFont;
		// self.devicePercentageLabel.adjustsFontSizeToFitWidth = TRUE;
        self.devicePercentageLabel.frame = self.bounds;
        self.devicePercentageLabel.clipsToBounds = TRUE;



        [self.circleBackgroundVisualEffectView.contentView addSubview:self.devicePercentageLabel];

        self.circleBackgroundVisualEffectView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.circleBackgroundVisualEffectView.widthAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
        [self.circleBackgroundVisualEffectView.heightAnchor constraintEqualToConstant:self.cellWidth].active = TRUE;
		// self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
		// [self.devicePercentageLabel.widthAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.widthAnchor].active = TRUE;
		// [self.devicePercentageLabel.heightAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.heightAnchor].active = TRUE;

        [self addArrangedSubview:self.circleBackgroundVisualEffectView];

        self.devicePercentageLabel.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.devicePercentageLabel.centerXAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerXAnchor].active = TRUE;
        [self.devicePercentageLabel.centerYAnchor constraintEqualToAnchor:self.circleBackgroundVisualEffectView.centerYAnchor].active = TRUE;

        // self.circleOutlinePath = [UIBezierPath bezierPath];
        self.circleOutlinePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleBackgroundVisualEffectView.contentView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.contentView.center.y+self.cellWidth/2)
            radius:self.cellWidth/2
            startAngle:[self degreesToRadians:(-90)]
            endAngle:[self degreesToRadians:(270)]
            clockwise:TRUE];
		// self.circleOutlinePath = [UIBezierPath bezierPathWithOvalInRect:self.circleBackgroundVisualEffectView.contentView.bounds];


        self.circleOutlineLayer = [[CAShapeLayer alloc] init];
        self.circleOutlineLayer.bounds = self.bounds;
        // self.circleOutlineLayer.position = self.circleBackgroundVisualEffectView.contentView.center;
        self.circleOutlineLayer.fillColor = [UIColor clearColor].CGColor;
        // self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		if(roundOutlineCorners){
			self.circleOutlineLayer.lineCap = kCALineCapRound;
		}
		self.circleOutlineLayer.strokeStart = 0;
		self.circleOutlineLayer.strokeEnd = 0;
        self.circleOutlineLayer.path = [self.circleOutlinePath CGPath];
        self.circleOutlineLayer.lineWidth = self.cellWidth/10;
		self.circleOutlineLayer.masksToBounds = FALSE;
        [self.layer addSublayer:self.circleOutlineLayer];
	

        self.deviceGlyphView = [[UIImageView alloc] initWithImage:connectedDevice.glyph];
		// [self.deviceGlyphView.widthAnchor constraintEqualToConstant:50].active = TRUE;
		self.deviceGlyphView.contentMode = UIViewContentModeScaleAspectFit;
		[self.deviceGlyphView.heightAnchor constraintEqualToConstant:self.cellWidth*0.6].active = TRUE;
		
        [self addArrangedSubview:self.deviceGlyphView];
		// [self.circleOutlineLayer setNeedsDisplay];
		[self.circleBackgroundVisualEffectView setNeedsDisplay];
        self.deviceName = connectedDevice.name;
        return self;
    }

    -(CGFloat)degreesToRadians:(CGFloat)arg1 {
        return arg1*(M_PI/180);
    }

    @synthesize cellWidth;

    -(CGFloat)getCellWidth {
        return cellWidth;
    }
    -(void)setCellWidth:(CGFloat)arg1 {
        cellWidth = arg1;
    }

    -(void)addPercentageSymbolToLabel {
		if(!hidePercent){
        	[self.devicePercentageString appendString:@"%"];
			// NSString *partsNum = [NSString stringWithFormat:@"%@"
		}
    }
    -(long long)getDevicePercentage {
        return [self.device percentCharge];
    }
	-(void)updateDevicePercentage {
		self.devicePercentage = [self getDevicePercentage];
	}
    -(void)updateDevicePercentageLabel {
		[self updateDevicePercentage];
        self.devicePercentageString = [NSMutableString stringWithFormat:@"%lld",self.devicePercentage];
		[self addPercentageSymbolToLabel];

        // self.devicePercentageString = string;
        self.devicePercentageLabel.text = self.devicePercentageString;
    }

	-(void)updateCircleOutline {
		// self.circleOutlinePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.circleBackgroundVisualEffectView.center.x+self.cellWidth/2,self.circleBackgroundVisualEffectView.center.y+self.cellWidth/2)
        //     radius:self.cellWidth/2
        //     startAngle:[self degreesToRadians:(-90)]
        //     endAngle:[self degreesToRadians:(3.6*(self.devicePercentage)-90)]
        //     clockwise:TRUE];

		[self.circleOutlineLayer setNeedsDisplay];
	}

	// -(void)animateOutlineLayer:(CGFloat)progress {
	// 	self.circleOutlineLayer.strokeEnd = progress;
	// }
	-(void)resetStrokeEnd {
		self.circleOutlineLayer.strokeEnd = 0;
	}
	-(void)removeFromSuperview {
		[super removeFromSuperview];
	}
	-(CGFloat)devicePercentageAsProgress {
		double progress;
		if(self.disconnected){
			progress = self.devicePercentage;
		}else{
			progress = [self getDevicePercentage];
		}
		return progress/100;
	}
	-(BOOL)isDeviceInternal {
		return [self.device isInternal];
	}
	-(BOOL)isLowPowerModeOn {
		return [self.device isBatterySaverModeActive];
	}
	-(BOOL)isBatteryLow {
		return [self.device isLowBattery];
	}
	-(void)updateOutlineColor {
		HBLogWarn(@"HOPST %@ DEVICE %lld", self.deviceName, [self.device percentCharge]);
		if([self isDeviceInternal]&&[self isLowPowerModeOn]&&![self.device isCharging]){
			self.circleOutlineLayer.strokeColor = lowPowerModeColor.CGColor;
		} else if([self isBatteryLow]&&(![self.device isCharging])){
			self.circleOutlineLayer.strokeColor = lowBatteryColor.CGColor;
		} else if([self.device isCharging]&&pulsateChargingOutline){
			// self.circleOutlineLayer.strokeColor = nil;
		} else if(self.device==nil){
			self.circleOutlineLayer.strokeColor = [UIColor systemGrayColor].CGColor;
			// self.circleOutlineLayer.strokeEnd = 100;
		} else if(!(self.device==nil)){
			self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		}else {
			self.circleOutlineLayer.strokeColor = normalBatteryColor.CGColor;
		}
	}
	-(void)pulsateOutline {
		if([self.device isCharging]){
			CAMediaTimingFunction *animationColorTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

			CABasicAnimation *normalToBright = [CABasicAnimation animationWithKeyPath:@"strokeColor"];	
			CABasicAnimation *brightToNormal = [CABasicAnimation animationWithKeyPath:@"strokeColor"];

			PulsateColorAnimationDelegate *normalToBrightDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:brightToNormal];
			normalToBright.delegate = normalToBrightDelegate;
			PulsateColorAnimationDelegate *brightToNormalDelegate = [[PulsateColorAnimationDelegate alloc] initWithCell:self nextAnimation:normalToBright];
			brightToNormal.delegate = brightToNormalDelegate;

			normalToBright.fromValue = id(normalBatteryColor.CGColor);
			normalToBright.toValue = id(brightGreen.CGColor);
			normalToBright.duration = 2;
			normalToBright.timingFunction = animationColorTimingFunction;
			[normalToBright setFillMode:kCAFillModeForwards];
			[normalToBright setRemovedOnCompletion:FALSE];

			brightToNormal.fromValue = normalToBright.toValue;
			brightToNormal.toValue = id(normalBatteryColor.CGColor);
			brightToNormal.duration = 2;
			brightToNormal.timingFunction = animationColorTimingFunction;
			[brightToNormal setFillMode:kCAFillModeForwards];
			[brightToNormal setRemovedOnCompletion:FALSE];
			
			// self.circleOutlineLayer.strokeColor = brightGreen.CGColor;
			[self.circleOutlineLayer addAnimation:normalToBright forKey:kCATransition];
		}
	}
	-(void)updatePercentageColor {
		if([self.device isCharging]){
			self.devicePercentageLabel.textColor = normalBatteryColor;
		}else {
			self.devicePercentageLabel.textColor = [UIColor labelColor];

		}
	}
	-(void)newAnimateOuterLayerToCurrentPercentage{
		// self.circleOutlineLayer.strokeEnd = 0;

		self.percentageAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
		StrokeEndAnimationDelegate *delegate = [[StrokeEndAnimationDelegate alloc] initWithCell:self];
		self.percentageAnimation.delegate = delegate;
		self.percentageAnimation.fromValue = @(0.0);
		self.percentageAnimation.toValue = @([self devicePercentageAsProgress]);
		self.percentageAnimation.duration = 0.3;
		[self.percentageAnimation setFillMode:kCAFillModeForwards];
		[self.percentageAnimation setRemovedOnCompletion:TRUE];
		CAMediaTimingFunction *animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		self.percentageAnimation.timingFunction = animationTimingFunction;
		
		[self.circleOutlineLayer addAnimation:self.percentageAnimation forKey:kCATransition];
	}
	-(void)newAnimateOuterLayerToZero {
		self.circleOutlineLayer.strokeEnd = 0;
	}


@end

@implementation VaonFavoriteContactsCell

-(instancetype)initWithFrame:(CGRect)arg1 favoriteEntry:(CNFavoriteEntry *)favoriteEntry {
	self = [super initWithFrame:arg1];
	self.axis = UILayoutConstraintAxisVertical;
	self.alignment = UIStackViewAlignmentCenter;
	self.distribution = UIStackViewDistributionEqualSpacing;
	self.spacing = 10;
	self.clipsToBounds = TRUE;
	self.backgroundColor = [UIColor clearColor];
	self.translatesAutoresizingMaskIntoConstraints = FALSE;

	self.favoriteEntry = favoriteEntry;
	self.contact = favoriteEntry.contact;


	self.contactNameLabel = [[UILabel alloc] init];
	self.contactNameLabel.text = [self.favoriteEntry originalName];
	self.contactNameLabel.adjustsFontSizeToFitWidth = TRUE;
	self.contactNameLabel.frame = self.bounds;
	self.contactNameLabel.clipsToBounds = TRUE;

	[self addArrangedSubview:self.contactNameLabel];

	NSData *imageData = self.contact.imageData;

	UIImage *contactImage = [UIImage imageWithData:imageData];
	self.contactImageView = [[UIImageView alloc] initWithImage:contactImage];
	self.contactImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.contactImageView.frame = self.bounds;
	self.contactImageView.clipsToBounds = TRUE;

	[self addArrangedSubview:self.contactImageView];

	return self;
}


@end






void initBatteryView(UIView *view){

	batteryScrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
	batteryScrollView.scrollsToTop = FALSE;
	batteryScrollView.directionalLockEnabled = TRUE;
	batteryScrollView.alwaysBounceVertical = FALSE;
	batteryScrollView.alwaysBounceHorizontal = FALSE;
	batteryScrollView.showsHorizontalScrollIndicator = TRUE;
	batteryScrollView.showsVerticalScrollIndicator = FALSE;
	// batteryScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	batteryHStackView = [[UIStackView alloc] initWithFrame:batteryScrollView.bounds];
	batteryHStackView.axis = UILayoutConstraintAxisHorizontal;
	batteryHStackView.alignment = UIStackViewAlignmentCenter;
	batteryHStackView.distribution = UIStackViewDistributionFill;
	batteryHStackView.spacing = 30;
	batteryHStackView.clipsToBounds = TRUE;

	[batteryScrollView setContentSize:CGSizeMake(1000, view.bounds.size.height)];


	connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

	[view addSubview:batteryScrollView];
	[batteryScrollView addSubview:batteryHStackView];

	if(!(currentSwitcherStyle==2)){
		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *cell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			if(![device isInternal]){
				[batteryHStackView addArrangedSubview:cell]; 
			} else {
				if(!hideInternal){
					[batteryHStackView addArrangedSubview:cell]; 
				}
			}
			// [batteryScrollView setContentSize:CGSizeMake(batteryHStackView.bounds.size.width, batteryHStackView.bounds.size.height)];

		}
	}
	batteryScrollView.translatesAutoresizingMaskIntoConstraints = FALSE;
	[batteryScrollView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[batteryScrollView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;
	[batteryScrollView.heightAnchor constraintEqualToAnchor:view.heightAnchor].active = TRUE;
	[batteryScrollView.widthAnchor constraintEqualToAnchor:view.widthAnchor].active = TRUE;

	batteryHStackView.translatesAutoresizingMaskIntoConstraints = FALSE;

	[batteryHStackView.centerXAnchor constraintEqualToAnchor:batteryScrollView.centerXAnchor].active = TRUE;
	[batteryHStackView.centerYAnchor constraintEqualToAnchor:batteryScrollView.centerYAnchor].active = TRUE;

}



void initFavoriteContactsView(UIView *view) {
	// favoriteContactsScrollView

	favoriteContactsHStackView = [[UIStackView alloc] initWithFrame:view.bounds];
	favoriteContactsHStackView.axis = UILayoutConstraintAxisHorizontal;
	favoriteContactsHStackView.alignment = UIStackViewAlignmentCenter;
	favoriteContactsHStackView.distribution = UIStackViewDistributionEqualCentering;
	favoriteContactsHStackView.spacing = 80;
	favoriteContactsHStackView.clipsToBounds = TRUE;

	[view addSubview:favoriteContactsHStackView];

	NSArray *contactFavorites = [[%c(CNFavorites) sharedInstance] entries];

	for(CNFavoriteEntry *entry in contactFavorites){
		VaonFavoriteContactsCell *cell = [[VaonFavoriteContactsCell alloc] initWithFrame:favoriteContactsHStackView.bounds favoriteEntry:entry];
		[favoriteContactsHStackView addArrangedSubview:cell];
	}

	favoriteContactsHStackView.translatesAutoresizingMaskIntoConstraints = false;

	[favoriteContactsHStackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = TRUE;
	[favoriteContactsHStackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor].active = TRUE;
}


void initBaseVaonView(UIView* view) {
	vaonViewBackgroundColor = [UIColor colorNamed:@"clearColor"];
	blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
	titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
	view.clipsToBounds = TRUE;
	view.layer.cornerRadius = vaonViewCornerRadius;
	view.alpha = 0;
	view.backgroundColor = vaonViewBackgroundColor;
	
	vaonBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	vaonBlurView.frame = view.bounds;
	vaonBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view addSubview:vaonBlurView];

}

void updateBattery(){
	dispatch_async(dispatch_get_main_queue(), ^{


		connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		NSMutableArray *subviewsToBeAdded = [[NSMutableArray alloc] init];
		NSMutableArray *oldDisconnectedSubviews = [[NSMutableArray alloc] init];



		// connectedBluetoothDevices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

		for(BCBatteryDevice *device in connectedBluetoothDevices){
			VaonDeviceBatteryCell *newCell = [[VaonDeviceBatteryCell alloc] initWithFrame:batteryHStackView.bounds device:device];
			NSMutableArray *cellDevices = [[NSMutableArray alloc] init];
			for(VaonDeviceBatteryCell *cell in batteryHStackView.subviews){
				if(!(cell.device==nil)){
					[cellDevices addObject:cell.device];
				}
			}
			if((![batteryHStackView.subviews containsObject:newCell]&&![deviceNames containsObject:device.name])){
				if(![device isInternal]){
					[subviewsToBeAdded addObject:newCell];
					[deviceNames addObject:newCell.deviceName];
				}else{
					if(!hideInternal){
						[subviewsToBeAdded addObject:newCell];
						[deviceNames addObject:newCell.deviceName];
					}
				}
			}
		}

		for(VaonDeviceBatteryCell *subview in subviewsToBeAdded){

			[batteryHStackView addArrangedSubview:subview];
			// [batteryScrollView setContentSize:CGSizeMake(batteryHStackView.bounds.size.width, batteryHStackView.bounds.size.height)];

			subview.alpha = 0;
			[UIView animateWithDuration:0.3 animations:^ {
				subview.alpha = 1;

			}
			completion:^(BOOL finished) {
				[subview newAnimateOuterLayerToCurrentPercentage];
				[subviewsToBeAdded removeObject:subview];
			}];	
		}

		for(VaonDeviceBatteryCell *subview in batteryHStackView.subviews){
			if([subview.device isConnected]){
				subview.disconnected = FALSE;
				// if([oldDisconnectedSubviews containsObject:subview]){
				[oldDisconnectedSubviews removeObject:subview];
				// }
			} else{
				if(keepDisconnectedDevices){
					subview.disconnected = TRUE;
					[oldDisconnectedSubviews addObject:subview];
				}
			}
			if((![connectedBluetoothDevices containsObject:subview.device] && ![subview.device isConnected]) || subview.device == nil ){
				if(keepDisconnectedDevices){

				
				}else{
					subview.alpha = 1;
					[UIView animateWithDuration:0.3 animations:^ {
						subview.alpha = 0;
					}
					completion:^(BOOL finished) {
						[subview removeFromSuperview];
						[deviceNames removeObject:subview.deviceName];
					}];	
				}

				
			}
			//loop through oldDisconnectedSubviews
			// if(![oldDisconnectedSubviews containsObject:subview]){
			if(!(subview.device==nil)){
				[subview updateDevicePercentageLabel];
				// [subview animateOutlineLayer:[subview devicePercentageAsProgress]];
				[subview updateOutlineColor];
				[subview updatePercentageColor];
				// [subview updateCircleOutline];
				// if(pulsateChargingOutline){
				// 	[subview pulsateOutline];
				// }
				[subview updateDevicePercentage];
			}else{
				[subview updateOutlineColor];

			}
		}

	}); 
}



void fadeViewIn(UIView *view, CGFloat duration){
	if(doneFadingIn==FALSE){
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 1;
	} 	
	completion:^(BOOL finished) {
		if([selectedModule isEqual:@"battery"]){
			updateBattery();
			if(fadeInCounter==0){

			for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
				if(finished){
						[subview newAnimateOuterLayerToCurrentPercentage];
					}
				}
				fadeInCounter++;
			}
		}
		doneFadingIn = TRUE;
	}];	
	}
}

void fadeViewOut(UIView *view, CGFloat duration){
	for(VaonDeviceBatteryCell *subview in [batteryHStackView arrangedSubviews]){
				[subview newAnimateOuterLayerToZero];
	}	
	[UIView animateWithDuration:duration animations:^ {
		view.alpha = 0;
	}
	completion:^(BOOL finished) {
		fadeInCounter = 0;
		if([selectedModule isEqual:@"battery"]){


		}
		doneFadingIn = FALSE;
	}];	
}




%group BatteryModeUpdates


%hook BCBatteryDevice

//maybe add -(void)_postDidChangeNotification;, -(void)addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;, -(void)_queue_addDeviceChangeHandler:(/*^block*/id)arg1 withIdentifier:(id)arg2 ;
	-(void)setCharging: (BOOL)arg1 {
		%orig;
		updateBattery();
	}
	-(void)setBatterSaveModeActive:(BOOL)arg1 {
		updateBattery();
		%orig;
	}
	-(void)setPercentCharge:(NSInteger)arg1 {
		if(arg1!=0){
			updateBattery();
		}
		%orig;
	}
	-(void)dealloc {
		%orig;
		updateBattery();
	}
 
 %end

 %hook BCBatteryDeviceController
	-(void)addDeviceChangeHandler:(id)arg1 withIdentifier:(id)arg2 {
		%orig;
		updateBattery();
	}
	-(void)removeDeviceChangeHandlerWithIdentifier:(id)arg1 {
		%orig;
		updateBattery();
	}

 %end

%end


%hook SBSwitcherAppSuggestionContentView

	//creates vaonview for normal/non-grid app switcher 
	-(void)didMoveToWindow {
		%orig;
		if(![selectedModule isEqual:@"none"]){
			CGFloat mainScreen = [[UIScreen mainScreen] bounds].size.height;
			if(!vaonViewIsInitialized&&!(currentSwitcherStyle==2)){

				vaonView = [[UIView alloc] init];

				initBaseVaonView(vaonView);

				if([selectedModule isEqual:@"battery"]){	
					initBatteryView(vaonView);
				}else if([selectedModule isEqual:@"favoriteContacts"]){
					initFavoriteContactsView(vaonView);
				}

				[self addSubview:vaonView];

				vaonView.translatesAutoresizingMaskIntoConstraints = false;
				if(customVerticalOffsetEnabled){
					[vaonView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-customVerticalOffset].active = TRUE;
				} else{
					[vaonView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant:-80].active = TRUE;
				}
				[vaonView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = TRUE;
				if(customWidthEnabled){
					[vaonView.widthAnchor constraintEqualToConstant:customWidth].active = TRUE;
				} else{
					[vaonView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
				}
				if(customHeightEnabled){
					[vaonView.heightAnchor constraintEqualToConstant:customHeight].active = TRUE;
				} else{
					[vaonView.heightAnchor constraintEqualToConstant:(0.12*mainScreen)].active = TRUE;
				}

				vaonViewIsInitialized = TRUE;
				if(mainAppSwitcherVC.sbActiveInterfaceOrientation==1){
					fadeViewIn(vaonView, 0.3);

				}
			}	
		}
		
	}
%end


%hook SBMainSwitcherViewController


	-(void)viewDidLoad {
		%orig;
		mainAppSwitcherVC = self;
		dockWidth = mainAppSwitcherVC.view.frame.size.width*0.943;	

		
		if(![selectedModule isEqual:@"none"]){	

			//initializes vaon for grid mode 
			if(currentSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
				if(!vaonViewIsInitialized){
					vaonGridView = [[UIView alloc] init];

					initBaseVaonView(vaonGridView);

					if([selectedModule isEqual:@"battery"]){	
						initBatteryView(vaonGridView);
					}else if([selectedModule isEqual:@"favoriteContacts"]){
						initFavoriteContactsView(vaonGridView);
					}
					
					[self.view addSubview:vaonGridView];

					vaonGridView.translatesAutoresizingMaskIntoConstraints = false;
					if(customVerticalOffsetEnabled){
						[vaonGridView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:customVerticalOffset].active = TRUE;
					} else{
						[vaonGridView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-80].active = TRUE;
					}
					[vaonGridView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = TRUE;
					if(customWidthEnabled){
						[vaonGridView.widthAnchor constraintEqualToConstant:customWidth].active = TRUE;
					} else{
						[vaonGridView.widthAnchor constraintEqualToConstant:dockWidth].active = TRUE;
					}
					if(customHeightEnabled){
						[vaonGridView.heightAnchor constraintEqualToConstant:customHeight].active = TRUE;
					} else{
						[vaonGridView.heightAnchor constraintEqualToConstant:113].active = TRUE;
					}
					vaonViewIsInitialized = TRUE;
				}
			}
		}
	}

	
	-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
		if (arg2 == FALSE && ![selectedModule isEqual:@"none"]) {
			// [UIView animateWithDuration:0.2 animations:^ {
			// 	vaonView.alpha = 0;
			// }];
			fadeViewOut(vaonView, 0.2);
		}
		%orig;
	}


	//fade out vaon when entering an app layout from the switcher
	-(void)_configureRequest:(id)arg1 forSwitcherTransitionRequest:(id)arg2 withEventLabel:(id)arg3 {
		if(![selectedModule isEqual:@"none"]){
			NSString *switcherTransitionRequest = [[NSString alloc] initWithFormat:@"%@", arg2];
			NSUInteger indexAfterAppLayout =  [switcherTransitionRequest rangeOfString: @"appLayout: "].location;
			NSString *appLayoutString = [switcherTransitionRequest substringFromIndex:indexAfterAppLayout];
			// FinalFluidSwitcherGestureAction
			NSString *eventLabel = [[NSString alloc] initWithFormat:@"%@", arg3];

			// if(!(currentSwitcherStyle==2)){
			if(![appLayoutString containsString:@"appLayout: 0x0;"]){		
				// [UIView animateWithDuration:0.2 animations:^ {
				// 	vaonView.alpha = 0;
				// }];
				fadeViewOut(vaonView, 0.2);
			}
			if([eventLabel isEqual:@"FinalFluidSwitcherGestureAction"]&&mainAppSwitcherVC.sbActiveInterfaceOrientation==1){

				fadeViewIn(vaonView, 0.3);


			}
			// }
		}
		%orig;
	}




	//fade in and out for vaon in grid mode
	-(void)_updateDisplayLayoutElementForLayoutState: (id)arg1 {
		%orig;
		if(![selectedModule isEqual:@"none"]){
			appSwitcherOpen = [self isAnySwitcherVisible];
			if(currentSwitcherStyle==2&&self.sbActiveInterfaceOrientation==1){
				if(!appSwitcherOpen){
				// if(doneFadingIn){
					fadeViewOut(vaonGridView, 0.3);
				}else{
					if(!(vaonGridView.alpha==1)){
						fadeViewIn(vaonGridView, 0.3);
					}
				}
			}
		}

	}



	%end


%hook SBAppSwitcherSettings

	//Enable and customize grid mode 
	-(void)setSwitcherStyle: (long long)arg1 {
		if(customSwitcherStyle==2){
			%orig(2);
		}else {
			%orig;
		}
		currentSwitcherStyle = self.switcherStyle;
	}

	- (void) setGridSwitcherPageScale: (double)arg1 {
		%orig(0.25);
	}

	-(void)setGridSwitcherVerticalNaturalSpacingPortrait: (double)arg1 {
		%orig(40);
	}
%end



%hook SBSwitcherAppSuggestionBannerView

	-(void)didMoveToWindow {
		%orig;
		if(hideSuggestionBanner){
			self.hidden = TRUE;
		}
	}
%end


%hook SBFluidSwitcherItemContainer

	- (void)setTitleOpacity:(double)arg1 {
		if(hideAppTitles){
			%orig(0);
		}else {
			%orig;
		}
	}

	// -(id)initWithFrame:(CGRect)arg1 {
	// 	return %orig(CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height));
	// }
	// -(void)setContentView:(UIView*)arg1 {
	// 	UIView *view = arg1;
	// 	view.frame = CGRectMake(arg1.frame.origin.x, arg1.frame.origin.y-200, arg1.frame.size.width, arg1.frame.size.height);
	// 	%orig(view);
	// }
	
	// -(CGRect)_frameForPageView {
	// 	return CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height);
	// 	// return CGRectMake(self._pageView.frame.origin.x, pageView.frame.origin.y-200, pageView.frame.size.width, pageView.frame.size.height);
	// }
	// -(CGRect)_frameForScrollView {
	// 	return CGRectMake(self.frame.origin.x, self.frame.origin.y-200, self.frame.size.width, self.frame.size.height);

	// }

%end

// %hook SBHomeGestureSettings

// 	- (void)setMinimumYDistanceForHomeOrAppSwitcher:(double)arg1 {
// 	    %orig(0);
// }

// %end

%hook SBFluidSwitcherAnimationSettings
	-(void)setEmptySwitcherDismissDelay:(double)arg1 {
		%orig(2);
	}
%end



// %hook SBAppSwitcherPageView
// 	// -(void)setFrame:(CGRect)frame {
// 	// 	%orig(CGRectMake(frame.origin.x, frame.origin.y-200, frame.size.width, frame.size.height));

// 	// }
// 	-(void)didMoveToWindow {
// 		%orig;
// 		// self.alpha = 0.5;
// 		// self.hidden = TRUE;
// 	}
// %end

// %hook SBGridSwitcherViewController

// 	-(void)viewDidLoad {
// 		%orig;
// 		self.viewIfLoaded.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-200, self.view.frame.size.width, self.view.frame.size.height);
// 	}
// %end


// %hook SBOrientationTransformWrapperView
// -(void)setFrame:(CGRect)arg1 {
// 		%orig(CGRectMake(arg1.origin.x, arg1.origin.y-500, arg1.size.width, arg1.size.height));
// 	}
// 	// -(void)setFrameOrigin:(CGPoint)arg1{
// 	// 	%orig(CGPointMake(arg1.x, arg1.y-200));
// 	// }
// 	// -(void)_constantsForVerticalAutoresizingConstraints:(double*)arg1 :(double*)arg2
// %end


void updateSettings(){
	[prefs registerBool:&isEnabled default:TRUE forKey:@"isEnabled"];
	[prefs registerObject:&switcherMode default:@"stock" forKey:@"switcherMode"];
	[prefs registerObject:&selectedModule default:@"battery" forKey:@"moduleSelection"];
	[prefs registerBool:&hideAppTitles default:FALSE forKey:@"hideAppTitles"];
	[prefs registerBool:&hideSuggestionBanner default:TRUE forKey:@"hideSuggestionBanner"];
	[prefs registerBool:&customHeightEnabled default:FALSE forKey:@"customHeightEnabled"];
	[prefs registerFloat:&customHeight default:113 forKey:@"customHeight"];
	[prefs registerBool:&customWidthEnabled default:FALSE forKey:@"customWidthEnabled"];
	[prefs registerFloat:&customWidth default:400 forKey:@"customWidth"];
	[prefs registerBool:&customVerticalOffsetEnabled default:FALSE forKey:@"customVerticalOffsetEnabled"];
	[prefs registerFloat:&customVerticalOffset default:-80 forKey:@"customVerticalOffset"];

	[prefs registerBool:&hideInternal default:FALSE forKey:@"hideInternal"];
	[prefs registerBool:&hidePercent default:FALSE forKey:@"hidePercent"];
	[prefs registerBool:&roundOutlineCorners default:TRUE forKey:@"roundOutlineCorners"];
	[prefs registerBool:&pulsateChargingOutline default:FALSE forKey:@"pulsateChargingOutline"];
	[prefs registerBool:&keepDisconnectedDevices default:FALSE forKey:@"keepDisconnectedDevices"];
	[prefs registerBool:&customBatteryCellSizeEnabled default:FALSE forKey:@"customBatteryCellSizeEnabled"];
	[prefs registerFloat:&customBatteryCellSize default:50 forKey:@"customBatteryCellSize"];
	[prefs registerBool:&customPercentageFontSizeEnabled default:FALSE forKey:@"customPercentageFontSizeEnabled"];
	[prefs registerFloat:&customPercentageFontSize default:12 forKey:@"customPercentageFontSize"];
}

%ctor {
	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.atar13.vaonprefs"];
	updateSettings();

	if([switcherMode isEqual:@"grid"]){
		customSwitcherStyle = 2;
	}else{
		currentSwitcherStyle = 0;
	}

	if(isEnabled){
		%init;
		if([selectedModule isEqual:@"battery"]){
			%init(BatteryModeUpdates);
		}
	}



}
