//
//  MetalPalettizer.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/17/26.
//

import Foundation
import Metal
import MetalKit
import CoreGraphics

class MetalPalettizer
{
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLComputePipelineState
    
    // Mirror of the Metal struct — must match layout exactly
    struct PaletteColor
    {
        var r: Float
        var g: Float
        var b: Float
        var a: Float = 1.0 // padding
    }
    
    init?()
    {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let queue = device.makeCommandQueue() else
        {
            return nil
        }
        
        self.device = device
        self.commandQueue = queue
        
        // Load the kernel from the default Metal library
        guard let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "palettizeKernel") else
        {
            return nil
        }
        
        do
        {
            pipelineState = try device.makeComputePipelineState(function: function)
        }
        catch
        {
            print("Failed to create pipeline: \(error)")
            return nil
        }
    }
    
    func palettize(image: CGImage,
                   palette: [(r: Float, g: Float, b: Float)]) -> CGImage? {
        let width = image.width
        let height = image.height
        
        // --- Input texture ---
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: width,
                                                                         height: height,
                                                                         mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        
        guard let inTexture = device.makeTexture(descriptor: textureDescriptor) else
        {
            return nil
        }
        
        // Upload CGImage pixels into the input texture
        let bytesPerRow = width * 4
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        guard let ctx = CGContext(data: &rawData,
                                  width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else
        {
            return nil
        }
        
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        inTexture.replace(region: MTLRegionMake2D(0, 0, width, height),
                          mipmapLevel: 0,
                          withBytes: &rawData,
                          bytesPerRow: bytesPerRow)
        
        // --- Output texture ---
        let outDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                     width: width,
                                                                     height: height,
                                                                     mipmapped: false)
        outDescriptor.usage = [.shaderWrite]
        // Needs to be shared so we can read back on CPU
        outDescriptor.storageMode = .shared
        
        guard let outTexture = device.makeTexture(descriptor: outDescriptor) else
        {
            return nil
        }
        
        // --- Palette buffer ---
        var paletteData = palette.map { PaletteColor(r: $0.r, g: $0.g, b: $0.b) }
        var paletteCount = UInt32(palette.count)
        
        guard let paletteBuffer = device.makeBuffer(bytes: &paletteData,
                                                    length: MemoryLayout<PaletteColor>.stride * palette.count,
                                                    options: .storageModeShared) else
        {
            return nil
        }
        
        // --- Encode and dispatch ---
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else
        {
            return nil
        }
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(inTexture, index: 0)
        encoder.setTexture(outTexture, index: 1)
        encoder.setBuffer(paletteBuffer, offset: 0, index: 0)
        encoder.setBytes(&paletteCount, length: MemoryLayout<UInt32>.size, index: 1)
        
        // Threadgroup sizing — use max threads the pipeline supports
        let threadgroupSize = MTLSize(width: pipelineState.threadExecutionWidth,
                                      height: pipelineState.maxTotalThreadsPerThreadgroup / pipelineState.threadExecutionWidth,
                                      depth: 1)
        // Non-uniform dispatch (iOS 11+, macOS 10.13+) — no manual bounds check needed
        // if you use this. We kept the bounds check in shader for safety.
        let gridSize = MTLSize(width: width, height: height, depth: 1)
        
        encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // --- Read back ---
        return cgImage(from: outTexture, width: width, height: height)
    }
    
    private func cgImage(from texture: MTLTexture, width: Int, height: Int) -> CGImage?
    {
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        texture.getBytes(&pixels,
                         bytesPerRow: bytesPerRow,
                         from: MTLRegionMake2D(0, 0, width, height),
                         mipmapLevel: 0)
        
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let cgImage = CGImage(width: width, height: height,
                                    bitsPerComponent: 8, bitsPerPixel: 32,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                    provider: provider,
                                    decode: nil, shouldInterpolate: false,
                                    intent: .defaultIntent) else
        {
            return nil
        }
        
        return cgImage
    }
}

/*
 guard let palettizer = MetalPalettizer() else
 {
 return
 }
 Task.detached(priority: .userInitialized)
 {
 let result = palettizer.palettize(image: someCGimage, palette [(float,float,float)]
 await MainActor.run
 {
 //use result
 }
 */
