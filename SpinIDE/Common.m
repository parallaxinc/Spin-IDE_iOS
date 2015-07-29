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
#include <net/if.h>

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
 * Locate all of the projects on disk and return a list of those projects.
 *
 * @return			A list of the existing projects as an array of NSString objects.
 */

+ (NSMutableArray *) findProjects {
    NSMutableArray *availableProjects = [[NSMutableArray alloc] init];
    
    NSString *sandBoxPath = [Common sandbox];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath: sandBoxPath error: nil];
    for (NSString *projectName in files) {
        NSString *fullPath = [sandBoxPath stringByAppendingPathComponent: projectName];
        BOOL isDirectory;
        if ([manager fileExistsAtPath: fullPath isDirectory: &isDirectory] && isDirectory) {
            NSString *projectPath = [fullPath stringByAppendingPathComponent: [projectName stringByAppendingPathExtension: @"side"]];
            if ([manager fileExistsAtPath: projectPath])
                [availableProjects addObject: projectName];
        }
    }
    
    return availableProjects;
}

/*!
 * Get the local IP address of this device on the connected network. This can be used as the base address
 * for scanning the network for XBee devices. It multiple connections exist, preference is given to iPv4 
 * WiFi networks.
 *
 * @return		The IP address for this device on the local network.
 */

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

+ (NSString *) getIPAddress {
    NSArray *searchArray = @[IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ];
    
    NSDictionary *addresses = [Common getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock: ^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         if (address) 
             *stop = YES;
     }];
    return address ? address : @"0.0.0.0";
}

/*!
 * Get the local IP addresses of this device on the connected network. There may be more than one, so the result
 * is an array.
 *
 * @return		The IP addresses for this device on the local network.
 */

+ (NSDictionary *) getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity: 8];
    
    // Retrieve the current interfaces - returns 0 on success.
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces.
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in *) interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String: interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *) interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat: @"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String: addrBuf];
                }
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

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
