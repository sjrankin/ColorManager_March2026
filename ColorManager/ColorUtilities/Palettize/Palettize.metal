//
//  Palettize.metal
//  ColorManager
//
//  Created by Stuart Rankin on 4/17/26.
//

#include <metal_stdlib>
using namespace metal;

struct PaletteColor
{
    float r;
    float g;
    float b;
    float a; // padding to 16 bytes for alignment
};

kernel void palettizeKernel(texture2d<float, access::read>  inTexture  [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant PaletteColor* palette [[buffer(0)]],
                            constant uint& paletteCount [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    // Bounds check
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) return;
    
    float4 pixel = inTexture.read(gid);
    
    float bestDist = INFINITY;
    float4 bestColor = float4(palette[0].r, palette[0].g, palette[0].b, 1.0);
    
    for (uint i = 0; i < paletteCount; i++)
    {
        float4 c = float4(palette[i].r, palette[i].g, palette[i].b, 1.0);
        
        // Weighted RGB perceptual distance (same approximation as before)
        float dr = pixel.r - c.r;
        float dg = pixel.g - c.g;
        float db = pixel.b - c.b;
        float dist = 2.0 * dr * dr + 4.0 * dg * dg + 3.0 * db * db;
        
        if (dist < bestDist)
        {
            bestDist = dist;
            bestColor = c;
        }
    }
    
    bestColor.a = pixel.a; // preserve original alpha
    outTexture.write(bestColor, gid);
}
