// CAR_AFNetworking.h
//
// Copyright (c) 2013 CAR_AFNetworking (http://afnetworking.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <Availability.h>

#ifndef _CAR_AFNETWORKING_
    #define _CAR_AFNETWORKING_

    #import "CAR_AFURLRequestSerialization.h"
    #import "CAR_AFURLResponseSerialization.h"
    #import "CAR_AFSecurityPolicy.h"
#if !TARGET_OS_WATCH
    #import "CAR_AFNetworkReachabilityManager.h"
    #import "CAR_AFURLConnectionOperation.h"
    #import "CAR_AFHTTPRequestOperation.h"
    #import "CAR_AFHTTPRequestOperationManager.h"
#endif

#if ( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
      ( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) || \
       TARGET_OS_WATCH )
    #import "CAR_AFURLSessionManager.h"
    #import "CAR_AFHTTPSessionManager.h"
#endif

#endif /* _CAR_AFNETWORKING_ */
