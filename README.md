ReallyRandom
============

ReallyRandom is an Objective-C class for retrieving truly random numbers from http://random.org. It supports both synchronous and asynchronous retrieval and lets you specify the range and the number of numbers to retrieve. It returns an NSArray* of NSNumbers containing the results, or nil if retrieval failed.


Usage:
======

ReallyRandom* r = [[ReallyRandom alloc] init];

// Synchronous
// Gets 5 numbers ranging from 1 to 10
NSArray* numbers = [r get:5 numbersInRange:1 to:10];
if(numbers != nil)
{
    // Do something with numbers
}


// Asynchronous
// Gets 5 numbers ranging from 1 to 10
[r getAsync:5 numbersInRange:1 to:10 withDelegate:self];

-(void) didGetResults:(NSArray*)results
{
    if(results != nil)
    {
	// Do something with numbers
    }
}



Enjoy! And feel free to use this code however you like.
