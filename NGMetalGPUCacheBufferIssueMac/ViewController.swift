//
//  ViewController.swift
//  NGMetalGPUCacheBufferIssueMac
//
//  Created by Noah Gilmore on 10/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    private var mtkView: MTKView!
    private var vertices: [VertexInOut]!
    private var vertexBuffer: MTLBuffer!
    private var pipelineState: MTLRenderPipelineState!

    override func viewDidLoad() {
        super.viewDidLoad()
        let device = MTLCreateSystemDefaultDevice()!
        mtkView = MTKView(frame: .zero, device: device)

        let vertices = [
            VertexInOut(position: SIMD4<Float>(0, 0.5, 0, 1), color: SIMD4<Float>(1, 0, 0, 1)),
            VertexInOut(position: SIMD4<Float>(-0.5, -0.5, 0, 1), color: SIMD4<Float>(0, 1, 0, 1)),
            VertexInOut(position: SIMD4<Float>(0.5, -0.5, 0, 1), color: SIMD4<Float>(0, 0, 1, 1)),
        ]
        guard let vertexBuffer = device.makeBuffer(
            bytes: UnsafeMutablePointer(mutating: vertices),
            length: MemoryLayout<VertexInOut>.size * vertices.count,
            options: [
//                .cpuCacheModeWriteCombined
            ]
        ) else {
            fatalError("Unable to allocate vertex buffer")
        }
        self.vertexBuffer = vertexBuffer
        self.vertices = vertices

        guard let shaderLibrary = device.makeDefaultLibrary() else {
            fatalError("Unable to find device library. Maybe bundle issue?")
        }
        guard let vertexFunction = shaderLibrary.makeFunction(name: "vertex_shader") else {
            fatalError("Unable to find vertex function. Are you sure you defined it and spelled the name right?")
        }
        guard let fragmentFunction = shaderLibrary.makeFunction(name: "fragment_shader") else {
            fatalError("Unable to find fragment function. Are you sure you defined it and spelled the name right?")
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Could not create pipeline state!")
        }
        self.pipelineState = pipelineState

        self.view.addSubview(mtkView)
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mtkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mtkView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mtkView.delegate = self

        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("Drawable size changed to: \(size)")
    }

    func draw(in view: MTKView) {
        guard let device = view.device else {
            print("Error: no metal device")
            return
        }

        guard let commandQueue = device.makeCommandQueue() else {
            print("Error: unable to make command queue")
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Error: unable to make command buffer")
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            print("Error: no render pass descriptor")
            return
        }

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("Error: no encoder")
            return
        }

        encoder.pushDebugGroup("Render")
        encoder.setRenderPipelineState(self.pipelineState)
        encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.popDebugGroup()
        encoder.endEncoding()

        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }

        commandBuffer.commit()
    }
}
