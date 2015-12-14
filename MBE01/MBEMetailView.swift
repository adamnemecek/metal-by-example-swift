//
//  MBEMetailView.swift
//  MBE01
//
//  Created by SOROKIN EVGENY on 12/12/15.
//  Copyright © 2015 Pacoca. All rights reserved.
//

import UIKit
import QuartzCore
import Metal
import simd

public class MBEMetailView: UIView {
    
    struct MBEVertex {
        var position: float4
        var color: float4
    }

    var device: MTLDevice?
    var vertexBuffer: MTLBuffer?
    var pipeline: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var displayLink: CADisplayLink?
    
    var metalLayer: CAMetalLayer {
        get {
            return self.layer as! CAMetalLayer
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeDevice()
        makeBuffers()
        makePipeline()
    }
    
    override public class func layerClass() -> AnyClass {
        return CAMetalLayer.self
    }
    
    override public func didMoveToWindow() {
        redraw()
    }
    
    func makeDevice() {
        device = MTLCreateSystemDefaultDevice()!
        metalLayer.device = device;
        metalLayer.pixelFormat = MTLPixelFormat.BGRA8Unorm;
    }
    
    func makeBuffers() {
        let vertices: [MBEVertex] = [
            MBEVertex(position: float4(0.0, 0.5, 0, 1), color: float4(1, 0, 0, 1)),
            MBEVertex(position: float4(-0.5, -0.5, 0, 1), color: float4(0, 1, 0, 1)),
            MBEVertex(position: float4(0.5, -0.5, 0, 1), color: float4(0, 0, 1, 1))
        ]
        vertexBuffer = device?.newBufferWithBytes(vertices, length: sizeof(MBEVertex) * vertices.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
    func makePipeline() {
        let library: MTLLibrary = (device?.newDefaultLibrary())!
        let vertexFunc: MTLFunction = library.newFunctionWithName("vertex_main")!
        let fragmentFunc: MTLFunction = library.newFunctionWithName("fragment_main")!
        
        var pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        
        pipeline = try! device!.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        
        commandQueue = device!.newCommandQueue()
    }
    
    func redraw() {
        let drawable: CAMetalDrawable = metalLayer.nextDrawable()!
        var texture: MTLTexture = drawable.texture
        var passDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear
        passDescriptor.colorAttachments[0].storeAction = MTLStoreAction.Store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1)
        
        var commandBuffer: MTLCommandBuffer = commandQueue!.commandBuffer()
        var commandEncoder: MTLRenderCommandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)
        commandEncoder.setRenderPipelineState(pipeline!)
        commandEncoder.setVertexBuffer(vertexBuffer!, offset: 0, atIndex: 0)
        commandEncoder.drawPrimitives(MTLPrimitiveType.Triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            displayLink = CADisplayLink(target: self, selector: "displayLinkDidFire:")
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    func displayLinkDidFire(displayLink: CADisplayLink) {
        redraw()
    }
}
