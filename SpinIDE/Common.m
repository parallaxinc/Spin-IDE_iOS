//
//  Common.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Common.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation Common

/*!
 * Get the path name of the sandbox as a c string.
 *
 * The path name is terminated with a / character.
 *
 * @return			The full path of the sandbox directory.
 */

+ (const char *) csandbox {
    NSString *path = [Common sandbox];
    if ([path characterAtIndex: path.length - 1] != '/')
        path = [path stringByAppendingString: @"/"];
    return [path UTF8String];
}

/*!
 * Get the local IP address of this iOS device on the connected network. This can be used as the base address
 * for scanning the network for XBee devices.
 *
 * @return		The IP address for this iOS device on the local network.
 */

+ (NSString *) getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // Retrieve the current interfaces - returns 0 on success.
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces.
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone.
                if ([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: @"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
// TODO: Dennis suggests this in an email of 9 Apr 15:
//- (NSString *)getLocalIPAddress
//{
//    NSArray *ipAddresses = [[NSHost currentHost] addresses];
//    NSArray *sortedIPAddresses = [ipAddresses sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    numberFormatter.allowsFloats = NO;
//    
//    for (NSString *potentialIPAddress in sortedIPAddresses)
//    {
//        if ([potentialIPAddress isEqualToString:@"127.0.0.1"]) {
//            continue;
//        }
//        
//        NSArray *ipParts = [potentialIPAddress componentsSeparatedByString:@"."];
//        
//        BOOL isMatch = YES;
//        
//        for (NSString *ipPart in ipParts) {
//            if (![numberFormatter numberFromString:ipPart]) {
//                isMatch = NO;
//                break;
//            }
//        }
//        if (isMatch) {
//            return potentialIPAddress;
//        }
//    }
//    
//    // No IP found
//    return @"?.?.?.?";
//}

// TODO: This method needs to move to the loader library, so move it out of Common.m.

// TODO: New suggestion from Dennis:

//- (NSString *) getIPAddress {
//    
//    SCDynamicStoreRef storeRef = SCDynamicStoreCreate(NULL, (CFStringRef)@"FindCurrentInterfaceIpMac", NULL, NULL);
//    CFPropertyListRef global = SCDynamicStoreCopyValue (storeRef,CFSTR("State:/Network/Interface"));
//    id primaryInterface = [(__bridge NSDictionary *)global valueForKey:@"Interfaces"];
//    NSString *ip;
//    
//    for (NSString* item in primaryInterface)
//    {
//        
//        if([self getTheAddress: (char *)[item UTF8String]])
//        {
//            ip = [NSString stringWithUTF8String:[self getTheAddress: (char *)[item UTF8String]]];
//            NSLog(@"interface: %@ - %@",item,ip);
//        } else
//            NSLog(@"interface: %@",item);
//    }
//    return ip;
//}
//
//- (char *) getTheAddress:(char *) interface {
//    int sock;
//    uint32_t ip;
//    struct ifreq ifr;
//    char *val;
//    
//    if (!interface)
//        return NULL;
//    
//    /* determine UDN according to MAC address */
//    sock = socket (AF_INET, SOCK_STREAM, 0);
//    if (sock < 0)
//    {
//        perror ("socket");
//        return NULL;
//    }
//    
//    strcpy (ifr.ifr_name, interface);
//    ifr.ifr_addr.sa_family = AF_INET;
//    
//    if (ioctl (sock, SIOCGIFADDR, &ifr) < 0)
//    {
//        perror ("ioctl");
//        close (sock);
//        return NULL;
//    }
//    
//    val = (char *) malloc (16 * sizeof (char));
//    ip = ((struct sockaddr_in *) &ifr.ifr_addr)->sin_addr.s_addr;
//    ip = ntohl (ip);
//    sprintf (val, "%d.%d.%d.%d",
//             (ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF);
//    
//    close (sock);
//    
//    return val;
//}

/*!
 * Get the value for the hide files preference.
 *
 * @return				YES to hide the file list in iPad landscape view, or NO to show it.
 */

+ (BOOL) hideFileListPreference {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hidePrograms = [defaults stringForKey: @"hide_files_preference"];
    if (hidePrograms != nil) {
        return [defaults boolForKey: @"hide_files_preference"];
    }
    return NO;
}

/*!
 * Universal entry point for reporting NSError errors tot he user.
 *
 * @param error		The error to report.
 */

+ (void) reportError: (NSError *) error {
    NSString *message = error.localizedDescription;
    if (error.localizedFailureReason)
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedFailureReason];
    if (error.localizedRecoverySuggestion)
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedRecoverySuggestion];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

/*!
 * Get the path name of the sandbox.
 *
 * @return			The full path of the sandbox directory.
 */

+ (NSString *) sandbox {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex: 0];
}

/*!
 * Get the prefered font for text in the console and source views.
 *
 * @return			The font.
 */

+ (UIFont *) textFont {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sizeString = [defaults stringForKey: @"font_size"];
	int size = 14;
    if (sizeString != nil) {
        size = [sizeString intValue];
        if (size < 9)
            size = 9;
        if (size > 24)
            size = 24;
    }
    return [UIFont fontWithName: @"Courier" size: size];
}

/*!
 * Return a list of the file extensions that are valid in projects and the editor.
 *
 * @return			An array of NSString objects with the valid file extensions.
 */

+ (NSArray *) validExtensions {
    NSMutableArray *extensions = [[NSMutableArray alloc] init];
    
    NSString *sandbox = [Common sandbox];
    NSString *path = [sandbox stringByAppendingPathComponent: @"extensions.txt"];
    NSError *error = nil;
    NSString *extensionsString = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: &error];
    
    if (!error && extensionsString != nil) {
        NSArray *extensionPrototypes = [extensionsString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        for (NSString *extension in extensionPrototypes) {
            NSString *trimmed = [extension stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmed && trimmed.length > 0)
                [extensions addObject: trimmed];
        }
    }
    
    if (extensions.count == 0)
        [extensions addObjectsFromArray: [NSArray arrayWithObjects: @"spin", @"c", @"cpp", @"h", nil]];
    
    return extensions;
}

@end
