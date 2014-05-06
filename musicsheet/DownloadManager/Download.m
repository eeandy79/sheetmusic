//
//  Download.m
//  TestingPlatform
//
//  Created by Robert Ryan on 11/13/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "Download.h"

@interface Download () <NSURLConnectionDelegate>

@property (strong, nonatomic) NSOutputStream *downloadStream;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *tempFilename;

@end

@implementation Download

@synthesize filename;
@synthesize url;
@synthesize delegate;
@synthesize error;
@synthesize progressContentLength;
@synthesize downloading;
@synthesize expectedContentLength;
@synthesize connection;
@synthesize tempFilename;
@synthesize downloadStream;

#pragma mark - Public methods

- (id)initWithFilename:(NSString *)_filename URL:(NSURL *)_url delegate:(id<DownloadDelegate>)_delegate
{
    self = [super init];
    
    if (self)
    {
        self.filename = _filename;
        self.url = _url;
        self.delegate = _delegate;
    }
    
    return self;
}

- (void)start
{
    // initialize progress variables
    
    self.downloading = YES;
    self.expectedContentLength = -1;
    self.progressContentLength = 0;
    
    // create the download file stream (so we can write the file as we download it
    
    self.tempFilename = [self pathForTemporaryFileWithPrefix:@"downloads"];
    self.downloadStream = [NSOutputStream outputStreamToFileAtPath:self.tempFilename append:NO];
    if (!self.downloadStream)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Unable to create NSOutputStream" forKey:@"message"];
        [dict setValue:self.tempFilename forKey:@"path"];
        
        self.error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                         code:-1
                                     userInfo:dict];
        
        [self cleanupConnectionSuccessful:NO];
        return;
    }
    [self.downloadStream open];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    if (!request)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Unable to create URL" forKey:@"message"];
        [dict setValue:self.url forKey:@"URL"];
        
        self.error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                         code:-1
                                     userInfo:dict];
        
        [self cleanupConnectionSuccessful:NO];
        return;
    }
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!self.connection)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Unable to create NSURLConnection" forKey:@"message"];
        [dict setValue:request forKey:@"NSURLRequest"];
        
        self.error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                         code:-1
                                     userInfo:dict];
        
        [self cleanupConnectionSuccessful:NO];
    }
}

- (void)cancel
{
    [self cleanupConnectionSuccessful:NO];
}

#pragma mark - Private methods

- (BOOL)createFolderForPath:(NSString *)filePath
{
    NSError *_error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [filePath stringByDeletingLastPathComponent];
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:folder isDirectory:&isDirectory])
    {
        // if folder doesn't exist, try to create it
        
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&_error];
        
        // if fail, report error

        if (self.error)
        {
            self.error = _error;
            return FALSE;
        }
        
        // directory successfully created
        
        return TRUE;
    }
    else if (!isDirectory)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Unable to create directory, file exists by that name" forKey:@"message"];
        [dict setValue:folder forKey:@"folder"];
        
        self.error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                         code:-1
                                     userInfo:dict];
        return FALSE;
    }
    
    // directory already existed
    
    return TRUE;
}

- (void)cleanupConnectionSuccessful:(BOOL)success
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *_error;

    // clean up connection and download steam
    
    if (self.connection != nil)
    {
        if (!success)
            [self.connection cancel];
        self.connection = nil;
    }
    if (self.downloadStream != nil)
    {
        [self.downloadStream close];
        self.downloadStream = nil;
    }
    
    self.downloading = NO;
    
    // if successful, move file and clean up, otherwise just cleanup
    
    if (success)
    {
        if (![self createFolderForPath:self.filename])
        {
            [self.delegate downloadDidFail:self];
            return;
        }

        if ([fileManager fileExistsAtPath:self.filename])
        {
            [fileManager removeItemAtPath:self.filename error:&_error];
            if (_error)
            {
                self.error = _error;
                [self.delegate downloadDidFail:self];
                return;
            }
        }
        
        [fileManager copyItemAtPath:self.tempFilename toPath:self.filename error:&_error];
        if (error)
        {
            self.error = _error;
            [self.delegate downloadDidFail:self];
            return;
        }

        [fileManager removeItemAtPath:self.tempFilename error:&_error];
        if (_error)
        {
            self.error = _error;
            [self.delegate downloadDidFail:self];
            return;
        }

        [self.delegate downloadDidFinishLoading:self];
    }
    else
    {
        if (self.tempFilename)
            if ([fileManager fileExistsAtPath:self.tempFilename])
                [fileManager removeItemAtPath:self.tempFilename error:&_error];
        
        [self.delegate downloadDidFail:self];
    }
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (id)response;
        
        NSInteger statusCode = [httpResponse statusCode];
        
        if (statusCode == 200)
        {
            self.expectedContentLength = [response expectedContentLength];
        }
        else if (statusCode >= 400)
        {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setValue:@"bad HTTP response status code" forKey:@"message"];
            [dict setValue:response forKey:@"NSHTTPURLResponse"];
            
            self.error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                             code:statusCode
                                         userInfo:dict];
            [self cleanupConnectionSuccessful:NO];
        }
    }
    else
    {
        self.expectedContentLength = -1;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSInteger       dataLength = [data length];
    const uint8_t * dataBytes  = [data bytes];
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.downloadStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self cleanupConnectionSuccessful:NO];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
    
    self.progressContentLength += dataLength;
    
    if ([self.delegate respondsToSelector:@selector(downloadDidReceiveData:)])
        [self.delegate downloadDidReceiveData:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupConnectionSuccessful:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)_error
{
    self.error = _error;
    
    [self cleanupConnectionSuccessful:NO];
}

@end
