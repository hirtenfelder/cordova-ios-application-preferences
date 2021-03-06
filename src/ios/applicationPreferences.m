/*
 applicationPreferences.m 

 Created by Tue Topholm on 31/01/11.
 Reused and updated by Raphael Hirtenfelder 17/03/16.
*/
#import "applicationPreferences.h"

@implementation applicationPreferences

- (void) getSetting:(CDVInvokedUrlCommand*)command 
{
    NSString* callback = command.callbackId;
	NSArray *arguments = command.arguments;
	NSDictionary *options = [arguments objectAtIndex:0];        
	NSString *settingsName = [options objectForKey:@"key"];
    CDVPluginResult* result = nil;

    @try 
    {
        //At the moment we only return strings
        //bool: true = 1, false=0
        NSString *returnVar = [[NSUserDefaults standardUserDefaults] stringForKey:settingsName];
        if(returnVar == nil)
        {
            returnVar = [self getSettingFromBundle:settingsName]; //Parsing Root.plist
			if (returnVar == nil) 
				@throw [NSException exceptionWithName:nil reason:@"Key not found" userInfo:nil];;
			}
			result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnVar];	
		}
		@catch (NSException * e) 
		{
			result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:[e reason]];
		}
		@finally 
		{
			[self.commandDelegate sendPluginResult:result callbackId:callback];
		}
}

- (void) setSetting:(CDVInvokedUrlCommand*)command
{
    NSString* callback = command.callbackId;
    NSArray *arguments = command.arguments;
	NSDictionary *options = [arguments objectAtIndex:0];
    CDVPluginResult* result;
    NSString *settingsName = [options objectForKey:@"key"];
    NSString *settingsValue = [options objectForKey:@"value"];
	
    @try 
    {
        [[NSUserDefaults standardUserDefaults] setValue:settingsValue forKey:settingsName];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];	
    }
    @catch (NSException * e) 
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:[e reason]];
    }
    @finally 
    {
        [self.commandDelegate sendPluginResult:result callbackId:callback];
    }
}

/*
  Parsing the Root.plist for the key, because there is a bug/feature in Settings.bundle
  So if the user haven't entered the Settings for the app, the default values aren't accessible through NSUserDefaults.
*/

- (NSString*) getSettingFromBundle:(NSString*)settingsName
{
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray)
	{
        if ([[prefItem objectForKey:@"Key"] isEqualToString:settingsName]) 
			return [prefItem objectForKey:@"DefaultValue"];		
	}
	return nil;	
}
@end