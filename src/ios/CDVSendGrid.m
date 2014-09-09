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

        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:email];

        NSString *apiUser = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApiUser"];

        [parameters setObject:apiUser forKey:@"api_user"];

        NSString *apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApiKey"];

        [parameters setObject:apiKey forKey:@"api_key"];


        if ([email objectForKey:@"bcc"])
            [parameters setObject:[email objectForKey:@"bcc"] forKey:@"bcc"];

        if ([email objectForKey:@"toname"])
            [parameters setObject:[email objectForKey:@"toname"] forKey:@"toname"];

        if ([email objectForKey:@"fromname"])
            [parameters setObject:[email objectForKey:@"fromname"] forKey:@"fromname"];

        if ([email objectForKey:@"replyto"])
            [parameters setObject:[email objectForKey:@"replyto"] forKey:@"replyto"];


        [self sendAsynchronousRequest:URL block:^(NSDictionary *result, NSError *error) {
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


- (void)sendAsynchronousRequest:(NSURL*)url block:(void (^)(NSDictionary * result, NSError *error))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

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

@end
