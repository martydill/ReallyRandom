
// ReallyRandom.m
// A class for retrieving truly random numbers from http://random.org
// Written by Marty Dill.
// This code is public domain. You can do anything you want with it.

#import "ReallyRandom.h"
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSURLResponse.h>
#import <Foundation/NSURLRequest.h>


// The maximum amount of time to wait before failing a request.
const int ReallyRandomRequestTimeout = 10.0;


// Helper method that returns an array of NSNumbers from an NSData object
NSArray* getNumberListForData(NSData* data)
{
    // The results come back as a series of numbers, one per line.
    // We need to parse out the number on each line.
    NSString* str = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    NSArray* lines = [str componentsSeparatedByString:@"\n"];
    
    NSMutableArray* numbers = [[NSMutableArray alloc] initWithCapacity:lines.count];
    for (NSString* line in lines)
    {
        // The last line might be empty ...
        if([line length] > 0)
        {
            int number = [line intValue];
            [numbers addObject:[NSNumber numberWithInt:number]];
        }
    }
    
    return numbers;
}



// Interface for helper class that encapsulates the data of an async request
@interface ReallyRandomAsyncConnection : NSObject

@property (nonatomic, retain) NSMutableData* allData;
@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) NSURLConnection* connection;

@end


// Helper class that encapsulates the data of an async request
@implementation ReallyRandomAsyncConnection

@synthesize allData;
@synthesize delegate;
@synthesize timer;
@synthesize connection;

// Init the helper class with the specified delegate
-(id)initWithDelegate:(id)del
{
    if(self = [super init])
    {
        self.delegate = del; 
        self.allData = [[NSMutableData alloc] init];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:ReallyRandomRequestTimeout
                                         target:self
                                       selector:@selector(onTimeExpired)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    return self;
}

// When time expires, cancel the connection and fire the delegate
-(void)onTimeExpired
{
    [self.connection cancel];
    [self.delegate didGetResults: nil];
}


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    // Don't really care...
}


// When we receive data, add it to our collection of data
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [allData appendData:data];
}


// If the connection fails, cancel the timer and fire the delegate
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    [self.timer invalidate];
    [self.delegate didGetResults: nil];
}


// If the connection has completed, cancel the timer and fire the delegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.timer invalidate];
    NSArray* numbers = getNumberListForData(allData);
    [self.delegate didGetResults: numbers];
}


@end


@implementation ReallyRandom


// The URL that we are requesting our numbers from
static NSString* BaseUrl = @"http://www.random.org/integers/?num=%d&min=%d&max=%d&col=1&base=10&format=plain&rnd=new";


// Returns an array of the specified number of NSNumbers in the specified range. Synchronous.
-(NSArray*)get:(int)howMany numbersInRange:(int)minValue to:(int)maxValue
{
    // TODO - use NSError?
    if(minValue > maxValue)
        return nil;
    if(howMany < 1)
        return nil;
    
    // Build up an HTTP request
    NSString* httpGetUrl = [NSString stringWithFormat:BaseUrl, howMany, minValue, maxValue];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:httpGetUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];

    // Request the data
    NSURLResponse* response = nil;
 
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
   
    NSArray* numbers = getNumberListForData(data);
    return numbers;
}


// Returns an array of the specified number of NSNumbers in the specified range. Asynchronous.
// Calls the specified delegate when complete.
-(void) getAsync:(int)howMany numbersInRange:(int)minValue to:(int)maxValue withDelegate:(id)delegate
{
    // TODO - use NSError?
    if(minValue > maxValue)
        return;
    if(howMany < 1)
        return;
    
    // Build up an HTTP request
    NSString* httpGetUrl = [NSString stringWithFormat:BaseUrl, howMany, minValue, maxValue];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:httpGetUrl]];
    
    // Request the data asynchronously
    ReallyRandomAsyncConnection* asyncConnection = [[ReallyRandomAsyncConnection alloc] initWithDelegate:delegate];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest: request delegate: asyncConnection startImmediately:NO];
    asyncConnection.connection = connection;    
    [connection start];
}


@end
