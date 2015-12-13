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

public class MBEMetailView: UIView {
    
    let device = MTLCreateSystemDefaultDevice()
    
    var metalLayer: CAMetalLayer {
        get {
            return self.layer as! CAMetalLayer
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        metalLayer.device = device;
        metalLayer.pixelFormat = MTLPixelFormat.BGRA8Unorm;
    }
    
    override public class func layerClass() -> AnyClass {
        return CAMetalLayer.self
    }
    
    override public func didMoveToWindow() {
        redraw()
    }
    
    func redraw() {
        let drawable: CAMetalDrawable = metalLayer.nextDrawable()!
        var texture: MTLTexture = drawable.texture
        var passDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear
        passDescriptor.colorAttachments[0].storeAction = MTLStoreAction.Store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1)
        
        var commandQueue: MTLCommandQueue = device!.newCommandQueue()
        var commandBuffer: MTLCommandBuffer = commandQueue.commandBuffer()
        var commandEncoder: MTLCommandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)
        commandEncoder.endEncoding()
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
}
