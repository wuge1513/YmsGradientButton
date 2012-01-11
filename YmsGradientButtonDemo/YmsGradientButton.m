//
//  YmsGradientButton.m
//  ymsbuttons
//
//  Created by Charles Choi on 3/22/11.
//  Copyright 2011 Yummy Melon Software LLC. All rights reserved.
//

#import "YmsGradientButton.h"


@implementation YmsGradientButton
@synthesize resourceName;

- (void)awakeFromNib {
    [super awakeFromNib];
	
    if (self.resourceName == nil) {
        self.resourceName = @"YmsGradientButton";
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
    NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    if ([self validateConfiguration:buttonConfig]) {
        [self configureShadow:buttonConfig];
        [self genGradientForState:UIControlStateNormal withConfig:buttonConfig];        
        [self genGradientForState:UIControlStateHighlighted withConfig:buttonConfig];        
        [self genGradientForState:UIControlStateDisabled withConfig:buttonConfig];        
        
        [self.layer setNeedsDisplay];
    }
    else {
        [NSException raise:@"Invalid YmsGradientButton Configuration" 
                    format:@"Please revise the file %@.plist to confirm that it has legal values.", self.resourceName];
    }
}


- (BOOL)validateConfiguration:(NSDictionary *)buttonConfig {
    BOOL result = YES;
    
    NSArray *states = [[NSArray alloc] initWithObjects:@"normal", @"highlighted", @"disabled", nil];
    
    for (NSString *stateName in states) {
        NSArray *colorArray = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"colors"];
        NSArray *locations = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"locations"];
        
        NSNumber *textColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"textColor"];
        NSNumber *cornerRadius = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"cornerRadius"];
        NSNumber *borderColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderColor"];
        NSNumber *borderWidth = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderWidth"];
        
        if ((colorArray == nil) || (colorArray.count == 0)) { 
            NSLog(@"ERROR: colors array is not defined in the %@ section of %@.plist", stateName, self.resourceName);
            result = result | NO;
        }
        else {
            if (locations != nil) {
                if (colorArray.count < locations.count)
                    NSLog(@"WARNING: colors and locations array count mismatch in the %@ section of %@.plist. " 
                          "They should either be equal or there should be no elements in the locations array.", stateName, self.resourceName);
                
                else if ((colorArray.count > locations.count) && (locations.count > 0)) {
                    NSLog(@"ERROR:The size of the array colors and the array locations do not match in the %@ section of %@.plist. "
                          "They should either be equal or there should be no elements in the locations array.", stateName, self.resourceName);
                    result = result | NO;
                }
            }
        }
        
        if (textColor == nil) {
            NSLog(@"ERROR: textColor is not defined in the %@ section of %@.plist", stateName, self.resourceName);
            result = result | NO;
        }
        
        if (cornerRadius == nil) {
            NSLog(@"ERROR: cornerRadius is not defined in the %@ section of %@.plist", stateName, self.resourceName);
            result = result | NO;
        }

        if (borderColor == nil) {
            NSLog(@"ERROR: borderColor is not defined in the %@ section of %@.plist", stateName, self.resourceName);
            result = result | NO;
        }
        
        if (borderWidth == nil) {
            NSLog(@"ERROR: borderWidth is not defined in the %@ section of %@.plist", stateName, self.resourceName);
            result = result | NO;
        }
    }

    NSDictionary *shadow = (NSDictionary *)[buttonConfig objectForKey:@"shadow"];

    if (shadow != nil) {
        NSNumber *enable = (NSNumber *)[shadow objectForKey:@"enable"];
        NSArray *shadowOffset = (NSArray *)[shadow objectForKey:@"shadowOffset"];
        NSArray *anchorPoint = (NSArray *)[shadow objectForKey:@"anchorPoint"];
        NSNumber *shadowOpacity = (NSNumber *)[shadow objectForKey:@"shadowOpacity"];
        NSNumber *shadowColor = (NSNumber *)[shadow objectForKey:@"shadowColor"];
        NSNumber *shadowRadius = (NSNumber *)[shadow objectForKey:@"shadowRadius"];
        
        if (enable == nil) {
            NSLog(@"ERROR: enable is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        
        if (shadowOffset == nil) {
            NSLog(@"ERROR: shadowOffset is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        else if (shadowOffset.count < 2) {
            NSLog(@"ERROR: shadowOffset array size must be 2 in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }

        if (anchorPoint == nil) {
            NSLog(@"ERROR: anchorPoint is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        else if (anchorPoint.count < 2) {
            NSLog(@"ERROR: anchorPoint array size must be 2 in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        
        if (shadowOpacity == nil) {
            NSLog(@"ERROR: shadowOpacity is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }

        if (shadowColor == nil) {
            NSLog(@"ERROR: shadowColor is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        
        if (shadowRadius == nil) {
            NSLog(@"ERROR: shadowRadius is not defined in the shadow section of %@.plist", self.resourceName);
            result = result | NO;
        }
        
        

    }
    return result;
}


- (void)configureShadow:(NSDictionary *)buttonConfig {
    // Note that self.layer.masksToBounds should be set NO in order for the shadow to render.
    
    NSDictionary *shadow = (NSDictionary *)[buttonConfig objectForKey:@"shadow"];
    
    if (shadow != nil) {
        NSNumber *enable = (NSNumber *)[shadow objectForKey:@"enable"];
        
        if ([enable boolValue]) {
            NSArray *shadowOffset = (NSArray *)[shadow objectForKey:@"shadowOffset"];
            NSArray *anchorPoint = (NSArray *)[shadow objectForKey:@"anchorPoint"];
            NSNumber *shadowOpacity = (NSNumber *)[shadow objectForKey:@"shadowOpacity"];
            NSNumber *shadowColor = (NSNumber *)[shadow objectForKey:@"shadowColor"];
            NSNumber *shadowRadius = (NSNumber *)[shadow objectForKey:@"shadowRadius"];
            
            
            float x, y;
            int c = [shadowColor integerValue];
            
            x = [(NSNumber *)[shadowOffset objectAtIndex:0] floatValue];
            y = [(NSNumber *)[shadowOffset objectAtIndex:1] floatValue];
            self.layer.shadowOffset = CGSizeMake(x, y);
            
            x = [(NSNumber *)[anchorPoint objectAtIndex:0] floatValue];
            y = [(NSNumber *)[anchorPoint objectAtIndex:1] floatValue];
            self.layer.anchorPoint = CGPointMake(x, y);
            
            self.layer.shadowOpacity = [shadowOpacity floatValue];
            self.layer.shadowRadius = [shadowRadius floatValue];
            self.layer.shadowColor = [RGBCSS(c) CGColor];
        }
    }

}


- (CAGradientLayer *)configureGradientForState:(UIControlState)aState withConfig:(NSDictionary *)buttonConfig {

	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	
    [gradientLayer setBounds:[self bounds]];
	[gradientLayer setPosition:CGPointMake([self bounds].size.width/2,
										   [self bounds].size.height/2)];
    
    NSString *stateName;
    
    if (aState == UIControlStateNormal) {
        stateName = @"normal";
    }
	
	else if (aState == UIControlStateHighlighted) {
        stateName = @"highlighted";
	}
	
	else if (aState == UIControlStateDisabled) {
        stateName = @"disabled";
	}
    
    NSArray *colorArray = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"colors"];
    NSArray *locations = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"locations"];
    
    NSNumber *textColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"textColor"];
    NSNumber *cornerRadius = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"cornerRadius"];
    NSNumber *borderColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderColor"];
    int borderColorValue = [borderColor integerValue];
    NSNumber *borderWidth = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderWidth"];
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    for (NSNumber *num in colorArray) {
        int n = [num integerValue];
        [colors addObject:(id)[RGBCSS(n) CGColor]];
    }
    
    [gradientLayer setColors:colors];
    
    if ([locations count] > 0)
        [gradientLayer setLocations:locations];
    
    int n = [textColor integerValue];
    [self setTitleColor:RGBCSS(n) forState:aState];
    gradientLayer.cornerRadius = [cornerRadius integerValue];
    gradientLayer.masksToBounds = YES;
    gradientLayer.borderColor = [RGBCSS(borderColorValue) CGColor];
    gradientLayer.borderWidth = [borderWidth floatValue];
    
	return gradientLayer;
}


- (void)genGradientForState:(UIControlState)aState withConfig:(NSDictionary *)buttonConfig {
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CAGradientLayer *gradientLayer = [self configureGradientForState:aState withConfig:buttonConfig];
	[gradientLayer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	[self setBackgroundImage:image forState:aState];
}


@end