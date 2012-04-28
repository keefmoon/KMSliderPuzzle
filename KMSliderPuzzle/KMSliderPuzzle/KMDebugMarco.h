//
//  KMDebugMarco.h
//  KMSliderPuzzle
//
//  Created by Keith Moon on 28/04/2012.
//  Copyright (c) 2012 Data Ninjitsu Limited. All rights reserved.
//

#if DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)
