//
//  ContentViewModel.swift
//
//  Based on code from an article by Benoit Pasquier:
//  https://benoitpasquier.com/webcam-utility-app-macos-swiftui/
//

import AppKit
import AVFoundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var isGranted: Bool = false
    var captureSession: AVCaptureSession!
    var capturePhotoOutput: AVCapturePhotoOutput!
    
    private var captureOutput: AVCapturePhotoCaptureDelegate
    private var cancellables = Set<AnyCancellable>()

    init() {
        capturePhotoOutput = AVCapturePhotoOutput()
        captureSession = AVCaptureSession()
        captureOutput = CapturePhotoDelegate()
        
        captureSession!.addOutput(capturePhotoOutput!)
        
        setupBindings()
    }

    func setupBindings() {
        $isGranted
            .sink { [weak self] isGranted in
                if isGranted {
                    self?.prepareCamera()
                } else {
                    self?.stopSession()
                }
            }
            .store(in: &cancellables)
    }

    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.isGranted = true

            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        DispatchQueue.main.async {
                            self?.isGranted = granted
                        }
                    }
                }

            case .denied: // The user has previously denied access.
                self.isGranted = false
                return

            case .restricted: // The user can't grant access due to restrictions.
                self.isGranted = false
                return
        @unknown default:
            fatalError()
        }
    }

    func startSession() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }

    func stopSession() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

    func prepareCamera() {
        captureSession.sessionPreset = .high

        if let device = AVCaptureDevice.default(for: .video) {
            startSessionForDevice(device)
        }
    }

    func startSessionForDevice(_ device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            addInput(input)
            startSession()
        }
        catch {
            print("Something went wrong - ", error.localizedDescription)
        }
    }

    func addInput(_ input: AVCaptureInput) {
        guard captureSession.canAddInput(input) == true else {
            return
        }
        captureSession.addInput(input)
    }
    
    func takePicture() {
        print("@@AWLC calling takePicture()")
        
        let settings = AVCapturePhotoSettings()
        
        capturePhotoOutput.capturePhoto(with: settings, delegate: captureOutput)
        
        print("@@AWLC done in takePicture()")
//        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
//                        (imageDataSampleBuffer, error) -> Void in
//                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//                         UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData), nil, nil, nil)
//                    }
    }


    
    
    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//
//                if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//                  print("image: \(UIImage(data: dataImage)?.size)") // Your Image
//                }
//            }
//        }
}


