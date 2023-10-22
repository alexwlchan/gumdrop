//
//  PlayerView.swift
//
//  Based on code from an article by Benoit Pasquier:
//  https://benoitpasquier.com/webcam-utility-app-macos-swiftui/
//

import AVFoundation
import SwiftUI

class PlayerView: NSView {
    
    var previewLayer: AVCaptureVideoPreviewLayer?

    init(captureSession: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        super.init(frame: .zero)

        previewLayer?.frame = self.frame
        previewLayer?.contentsGravity = .resizeAspectFill
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
        
        layer = previewLayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
