
// ReallyRandom.m
// A class for retrieving truly random numbers from http://random.org
// Written by Marty Dill.
// This code is public domain. You can do anything you want with it.

#import <UIKit/UIKit.h>


// ReallyRandom interface
@interface ReallyRandom : NSObject

-(NSArray*)get:(int)howMany numbersInRange:(int)minValue to:(int) maxValue;

-(void)getAsync:(int)howMany numbersInRange:(int)minValue to:(int) maxValue withDelegate:(id)delegate;

@end


// Definition of the callback 
@interface NSObject (ReallyRandomCallback)

// Callback method that returns an NSArray of NSNumbers
-(void)didGetResults:(NSArray*)results;

@end

