//
//  ContentViewModel.swift
//
//  Based on code from an article by Benoit Pasquier:
//  https://benoitpasquier.com/webcam-utility-app-macos-swiftui/
//

import AppKit
import AVFoundation
import Combine
import Photos

class ContentViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var messages: [String] = []
    
    @Published var isGranted: Bool = false
    var captureSession: AVCaptureSession!
    var capturePhotoOutput: AVCapturePhotoOutput!
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        capturePhotoOutput = AVCapturePhotoOutput()
        captureSession = AVCaptureSession()
        
        captureSession!.addOutput(capturePhotoOutput!)
        
        super.init()
        
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
        let settings = AVCapturePhotoSettings()
        
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            
            // Determine if the user previously authorized read/write access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized
            }
            
            return isAuthorized
        }
    }
    
    internal func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            let alert = NSAlert.init()
            alert.messageText = "Couldn’t save photo"
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        } else {
            Task {
                await save(photo: photo)
            }
        }
    }
    
    func save(photo: AVCapturePhoto) async {
        // Confirm the user granted read/write access.
        guard await isPhotoLibraryReadWriteAccessGranted else { return }
        
        // Create a data representation of the photo and its attachments.
        if let photoData = photo.fileDataRepresentation() {
            PHPhotoLibrary.shared().performChanges {
                // Save the photo data.
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = "gumdrop.jpg"
                creationRequest.addResource(with: .photo, data: photoData, options: options)
            } completionHandler: { success, error in
                if let error {
                    self.messages.append("Error saving photo: \(error.localizedDescription)")
                    print("Error saving photo: \(error.localizedDescription)")
                    return
                } else {
                    self.messages.append("Saved photo!")
                }
            }
        }
    }
}
