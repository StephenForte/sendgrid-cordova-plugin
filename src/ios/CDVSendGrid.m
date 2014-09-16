#import "CDVSendGrid.h"

NSString * const sgDomain = @"https://sendgrid.com/";
NSString * const sgEndpoint = @"api/mail.send.json";

@implementation CDVSendGrid

- (void)sendWithWeb:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;

    //Uses Web Api to send email
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@",sgDomain, sgEndpoint]];

    NSDictionary* email = [command.arguments objectAtIndex:0];

    if (email != nil) {
        NSString *apiUser = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApiUser"];
        NSString *apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApiKey"];


        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"api_user": apiUser, @"api_key": apiKey}];

        [parameters addEntriesFromDictionary:email];


        if ([email objectForKey:@"bcc"])
            [parameters setObject:[email objectForKey:@"bcc"] forKey:@"bcc"];

        if ([email objectForKey:@"toname"])
            [parameters setObject:[email objectForKey:@"toname"] forKey:@"toname"];

        if ([email objectForKey:@"fromname"])
            [parameters setObject:[email objectForKey:@"fromname"] forKey:@"fromname"];

        if ([email objectForKey:@"replyto"])
            [parameters setObject:[email objectForKey:@"replyto"] forKey:@"replyto"];


        [self sendAsynchronousRequest:URL data:parameters block:^(NSDictionary *result, NSError *error) {
            if (!error){
                if ([[result objectForKey:@"message"] isEqualToString:@"success"])
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                else
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:error.code];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            });
        }];
    }
}


- (void)sendAsynchronousRequest:(NSURL*)url data:(NSDictionary*)data block:(void (^)(NSDictionary * result, NSError *error))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:@"POST"];

    NSString *keyValueString = @"";
    NSError *error = nil;


    for (NSString *key in data.allKeys){

        NSString *value = [data objectForKey:key];

        NSString *fragment = [NSString stringWithFormat:@"%@=%@", key, [self urlencode:value]];

        keyValueString = [keyValueString stringByAppendingString:fragment];
        keyValueString = [keyValueString stringByAppendingString:@"&amp;"];
    }

    NSData *body = [keyValueString dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPBody:body];

    if (!error){
        NSLog(@"%@", error);
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSError *jsonParsingError = nil;

        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments  error:&jsonParsingError];

        if (jsonParsingError)
            error = jsonParsingError;

        block(result, error);

    }];

    [task resume];

}

- (NSString *)urlencode: (NSString*)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
