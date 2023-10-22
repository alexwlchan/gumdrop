//
//  PlayerContainerView.swift
//
//  Based on code from an article by Benoit Pasquier:
//  https://benoitpasquier.com/webcam-utility-app-macos-swiftui/
//

import AVFoundation
import SwiftUI

struct PlayerContainerView: NSViewRepresentable {
    typealias NSViewType = PlayerView

    let captureSession: AVCaptureSession

    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
    }

    func makeNSView(context: Context) -> PlayerView {
        return PlayerView(captureSession: captureSession)
    }

    func updateNSView(_ nsView: PlayerView, context: Context) { }
}

