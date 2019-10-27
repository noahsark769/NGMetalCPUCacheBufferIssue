//
//  Shaders.metal
//  NGMetalCPUCacheBufferIssue
//
//  Created by Noah Gilmore on 10/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInOut {
    /// Position of the vertex
    float4 position [[position]];

    /// Color of the vertex
    float4 color;
};

vertex VertexInOut vertex_shader(device VertexInOut *vertices [[buffer(0)]],
                                             uint vertexId [[vertex_id]])
{
    return vertices[vertexId];
}

fragment float4 fragment_shader(VertexInOut inVertex [[stage_in]]) {
    return inVertex.color;
}
