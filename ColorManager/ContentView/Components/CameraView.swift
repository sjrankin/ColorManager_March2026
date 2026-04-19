//
//  CameraView.swift
//  ColorManager
//
//  Created by Stuart Rankin on 4/17/26.
//
//  Required Info.plist keys:
//    NSCameraUsageDescription          (iOS + macOS)
//    NSPhotoLibraryAddUsageDescription (iOS only)

import Foundation
import SwiftUI
import AVFoundation
import Combine

#if os(iOS)
import UIKit
import Photos
#elseif os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

// MARK: - Camera View Model

/// Manages the AVCaptureSession, permission requests, photo capture, and live pixel sampling.
/// Not @MainActor — AVFoundation callbacks arrive on background queues.
/// All @Published mutations are dispatched back to the main queue.
class CameraViewModel: NSObject, ObservableObject
{
    @Published var permissionGranted: Bool = false
    @Published var permissionDenied: Bool = false
    @Published var isSessionRunning: Bool = false
    @Published var saveMessage: String = ""
    @Published var showSaveResult: Bool = false

    let session = AVCaptureSession()
    private let photoOutput     = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    // All session configuration and start/stop must run on this single serial queue
    private let sessionQueue = DispatchQueue(label: "com.colormanager.session")
    private let videoQueue   = DispatchQueue(label: "com.colormanager.videodata",
                                             qos: .userInteractive)

    // Thread-safe latest pixel buffer for color sampling
    private let bufferLock = NSLock()
    private var _latestPixelBuffer: CVPixelBuffer?

    private var captureCompletion: ((PlatformImage?) -> Void)?

    // MARK: Permission + session lifecycle

    func requestPermissionAndStart()
    {
        AVCaptureDevice.requestAccess(for: .video)
        { [weak self] granted in
            // Update UI state on main thread
            DispatchQueue.main.async
            {
                if granted
                {
                    self?.permissionGranted = true
                    self?.permissionDenied  = false
                }
                else
                {
                    self?.permissionGranted = false
                    self?.permissionDenied  = true
                }
            }
            // All session work on the dedicated serial queue
            if granted
            {
                self?.sessionQueue.async
                {
                    self?.configureSession()
                    self?.session.startRunning()
                    DispatchQueue.main.async { self?.isSessionRunning = true }
                }
            }
        }
    }

    private func configureSession()
    {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else
        {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else
        {
            session.commitConfiguration()
            return
        }
        session.addOutput(photoOutput)

        // Video data output for pixel-level color sampling
        videoDataOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(videoDataOutput)
        {
            session.addOutput(videoDataOutput)
        }

        session.commitConfiguration()
    }

    func startSession()
    {
        sessionQueue.async
        {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
        }
    }

    func stopSession()
    {
        sessionQueue.async
        {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isSessionRunning = false }
        }
    }

    // MARK: Color sampling

    /// Sample the color from the live camera feed at `point` inside a view of `viewSize`.
    /// Accounts for `resizeAspectFill` scaling so the point maps to the correct pixel.
    func colorAtPoint(_ point: CGPoint, in viewSize: CGSize) -> Color?
    {
        bufferLock.lock()
        let buffer = _latestPixelBuffer
        bufferLock.unlock()

        guard let pixelBuffer = buffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let bufW = CVPixelBufferGetWidth(pixelBuffer)
        let bufH = CVPixelBufferGetHeight(pixelBuffer)

        // resizeAspectFill: scale so both view dimensions are covered, then center-crop
        let fillScale = max(viewSize.width  / CGFloat(bufW),
                            viewSize.height / CGFloat(bufH))
        let offsetX = (CGFloat(bufW) * fillScale - viewSize.width)  / 2
        let offsetY = (CGFloat(bufH) * fillScale - viewSize.height) / 2

        let px = Int((point.x + offsetX) / fillScale)
        let py = Int((point.y + offsetY) / fillScale)

        guard px >= 0, px < bufW, py >= 0, py < bufH else { return nil }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pixel = base.advanced(by: py * bytesPerRow + px * 4)

        // Pixel format is BGRA
        let b = CGFloat(pixel.load(fromByteOffset: 0, as: UInt8.self)) / 255
        let g = CGFloat(pixel.load(fromByteOffset: 1, as: UInt8.self)) / 255
        let r = CGFloat(pixel.load(fromByteOffset: 2, as: UInt8.self)) / 255

        return Color(red: r, green: g, blue: b)
    }

    // MARK: Photo capture

    func capturePhoto(completion: @escaping (PlatformImage?) -> Void)
    {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: Save

    func saveImage(_ image: PlatformImage)
    {
#if os(iOS)
        saveToPhotoLibrary(image)
#elseif os(macOS)
        saveWithPanel(image)
#endif
    }

#if os(iOS)
    private func saveToPhotoLibrary(_ image: UIImage)
    {
        PHPhotoLibrary.requestAuthorization(for: .addOnly)
        { [weak self] status in
            guard status == .authorized || status == .limited else
            {
                DispatchQueue.main.async
                {
                    self?.saveMessage    = "Photo library access denied."
                    self?.showSaveResult = true
                }
                return
            }
            PHPhotoLibrary.shared().performChanges
            {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler:
            { success, error in
                DispatchQueue.main.async
                {
                    self?.saveMessage    = success ? "Saved to Photos." :
                        "Save failed: \(error?.localizedDescription ?? "unknown error")"
                    self?.showSaveResult = true
                }
            }
        }
    }
#endif

#if os(macOS)
    private func saveWithPanel(_ image: NSImage)
    {
        DispatchQueue.main.async
        {
            let panel = NSSavePanel()
            panel.allowedContentTypes    = [UTType.png]
            panel.nameFieldStringValue   = "CameraCapture.png"
            panel.message                = "Save camera capture"

            panel.begin
            { [weak self] response in
                guard response == .OK, let url = panel.url else { return }

                guard
                    let tiff   = image.tiffRepresentation,
                    let bitmap = NSBitmapImageRep(data: tiff),
                    let png    = bitmap.representation(using: .png, properties: [:])
                else
                {
                    self?.saveMessage    = "Could not encode image."
                    self?.showSaveResult = true
                    return
                }

                do
                {
                    try png.write(to: url)
                    self?.saveMessage = "Saved to \(url.lastPathComponent)."
                }
                catch
                {
                    self?.saveMessage = "Save failed: \(error.localizedDescription)"
                }
                self?.showSaveResult = true
            }
        }
    }
#endif
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewModel: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?)
    {
        guard error == nil,
              let data = photo.fileDataRepresentation()
        else
        {
            DispatchQueue.main.async { self.captureCompletion?(nil) }
            return
        }

#if os(iOS)
        let image: PlatformImage? = UIImage(data: data)
#else
        let image: PlatformImage? = NSImage(data: data)
#endif

        DispatchQueue.main.async
        {
            self.captureCompletion?(image)
            self.captureCompletion = nil
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        bufferLock.lock()
        _latestPixelBuffer = buffer
        bufferLock.unlock()
    }
}

// MARK: - Camera Preview (platform-specific)

#if os(iOS)
struct CameraPreviewView: UIViewRepresentable
{
    let session: AVCaptureSession

    func makeUIView(context: Context) -> _PreviewView { _PreviewView(session: session) }
    func updateUIView(_ view: _PreviewView, context: Context) {}

    class _PreviewView: UIView
    {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        private var previewLayer: AVCaptureVideoPreviewLayer
        { layer as! AVCaptureVideoPreviewLayer }

        init(session: AVCaptureSession)
        {
            super.init(frame: .zero)
            previewLayer.session      = session
            previewLayer.videoGravity = .resizeAspectFill
        }

        required init?(coder: NSCoder) { fatalError() }

        override func layoutSubviews()
        {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
    }
}
#elseif os(macOS)
struct CameraPreviewView: NSViewRepresentable
{
    let session: AVCaptureSession

    func makeNSView(context: Context) -> _PreviewView { _PreviewView(session: session) }
    func updateNSView(_ view: _PreviewView, context: Context) {}

    class _PreviewView: NSView
    {
        private let previewLayer = AVCaptureVideoPreviewLayer()

        init(session: AVCaptureSession)
        {
            super.init(frame: .zero)
            wantsLayer = true
            previewLayer.session      = session
            previewLayer.videoGravity = .resizeAspectFill
            layer?.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func layout()
        {
            super.layout()
            previewLayer.frame = bounds
        }
    }
}
#endif

// MARK: - Camera View

struct CameraView: View
{
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CameraViewModel()

    @State private var capturedImage: PlatformImage? = nil
    @State private var showingPreview: Bool = false
    @State private var sampledColor: Color? = nil
    @State private var sampledHex: String = ""

    var body: some View
    {
        ZStack
        {
            Color.black.ignoresSafeArea()

            if viewModel.permissionDenied
            {
                permissionDeniedView
            }
            else if viewModel.permissionGranted
            {
                if showingPreview, let img = capturedImage
                {
                    capturePreviewView(img)
                }
                else
                {
                    liveView
                }
            }
            else
            {
                ProgressView("Requesting camera access…")
                    .foregroundColor(.white)
            }
        }
        .onAppear   { viewModel.requestPermissionAndStart() }
        .onDisappear { viewModel.stopSession() }
        .alert("Save Result", isPresented: $viewModel.showSaveResult)
        { Button("OK") {} }
        message: { Text(viewModel.saveMessage) }
    }

    // MARK: Live view

    private var liveView: some View
    {
        VStack(spacing: 0)
        {
            // Camera preview — tapping samples the color at that point
            GeometryReader
            { geo in
                CameraPreviewView(session: viewModel.session)
                    .contentShape(Rectangle())
                    .onTapGesture
                    { location in
                        sampleColor(at: location, in: geo.size)
                    }
            }

            // Color sample bar
            colorSampleBar
                .frame(height: 52)

            // Shutter button below the camera display
            shutterButton
                .padding(.vertical, 16)
        }
    }

    // MARK: Color sample bar

    private var colorSampleBar: some View
    {
        HStack(spacing: 12)
        {
            if let color = sampledColor
            {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
                Text(sampledHex)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
            }
            else
            {
                Text("Tap the camera image to sample a color")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.9))
    }

    // MARK: Captured-image preview

    private func capturePreviewView(_ image: PlatformImage) -> some View
    {
        ZStack
        {
#if os(iOS)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
#else
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
#endif
            VStack
            {
                Spacer()
                HStack(spacing: 48)
                {
                    Button("Retake")
                    {
                        capturedImage  = nil
                        showingPreview = false
                        viewModel.startSession()
                    }
                    .cameraButtonStyle()

                    Button("Save")
                    {
                        viewModel.saveImage(image)
                    }
                    .cameraButtonStyle(bold: true)
                }
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: Permission denied

    private var permissionDeniedView: some View
    {
        VStack(spacing: 20)
        {
            Image(systemName: "camera.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Camera Access Required")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Please grant camera access in System Settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Button("Open Settings") { openSettings() }
                .cameraButtonStyle()
            Button("Dismiss") { dismiss() }
                .foregroundColor(.secondary)
        }
    }

    // MARK: Shutter button

    private var shutterButton: some View
    {
        Button
        {
            viewModel.capturePhoto
            { image in
                capturedImage  = image
                showingPreview = image != nil
            }
        } label: {
            ZStack
            {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 70, height: 70)
                Circle()
                    .fill(Color.white)
                    .frame(width: 56, height: 56)
            }
        }
#if os(macOS)
        .buttonStyle(.plain)
#endif
    }

    // MARK: Helpers

    private func sampleColor(at point: CGPoint, in size: CGSize)
    {
        guard let color = viewModel.colorAtPoint(point, in: size) else { return }
        sampledColor = color
        sampledHex   = hexString(from: color)
    }

    private func hexString(from color: Color) -> String
    {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
#if os(iOS)
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
#else
        (NSColor(color).usingColorSpace(.deviceRGB) ?? NSColor(color))
            .getRed(&r, green: &g, blue: &b, alpha: &a)
#endif
        return String(format: "#%02X%02X%02X",
                      Int((r * 255).rounded()),
                      Int((g * 255).rounded()),
                      Int((b * 255).rounded()))
    }

    private func openSettings()
    {
#if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString)
        { UIApplication.shared.open(url) }
#elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")
        { NSWorkspace.shared.open(url) }
#endif
    }
}

// MARK: - Button style helper

private extension View
{
    func cameraButtonStyle(bold: Bool = false) -> some View
    {
        self
            .font(bold ? .title3.bold() : .title3)
            .foregroundColor(.white)
    }
}
