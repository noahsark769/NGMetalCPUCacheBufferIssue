//
//  ShaderTypes.h
//  NGMetalCPUCacheBufferIssue
//
//  Created by Noah Gilmore on 10/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef struct {
    /// Position of the vertex
    vector_float4 position;

    /// Color of the vertex
    vector_float4 color;
} VertexInOut;


#endif /* ShaderTypes_h */
