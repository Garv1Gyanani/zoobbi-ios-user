import AVFoundation
import AudioToolbox
import SwiftUI

struct QRCodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var scanError: String?
    @State private var isScanned = false

    var onScanSuccess: (String) -> Void

    private let api = APIService.shared

    var body: some View {
        ZStack {
            // Real Camera Background
            ScannerView { code in
                if !isScanned && !isLoading {
                    handleScan(businessId: code)
                }
            }
            .ignoresSafeArea()

            // Header
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.darkGreen)
                        }
                        .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Text("QR Scanner")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)
                Spacer()
            }

            // Scanner Frame
            ScannerFrameOverlay()
                .frame(width: 260, height: 260)

            // Bottom UI
            VStack {
                Spacer()

                if let error = scanError {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }

                if isScanned {
                    Text("Successfully Scanned!")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }

                HStack {
                    Text("Align QR code inside frame")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.darkGreen)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.lightGreenBg)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 80)
            }

            if isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(AndroidCircularProgressViewStyle(tint: .white))
            }
        }
    }

    func handleScan(businessId: String) {
        var finalId = businessId

        // Check if the scanned string is a URL and extract the ID
        if let url = URL(string: businessId), 
           (url.host?.contains("zoobbi.com") == true || url.host?.contains("zoobbi.divanex.in") == true) {
            let components = url.pathComponents
            if let index = components.firstIndex(of: "business"), index + 1 < components.count {
                finalId = components[index + 1]
            }
        }

        AudioServicesPlaySystemSound(1057)  // Success sound

        // Fire scan API in background, do not block navigation
        api.scanBusiness(businessId: finalId) { _ in }

        // Navigate immediately to ensure instant feel response
        dismiss()
        onScanSuccess(finalId)
    }
}

struct ScannerFrameOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let s = geo.size
            let l: CGFloat = 50  // corner length
            let r: CGFloat = 24  // radius
            let w: CGFloat = 4  // width
            let color = Color.brightGreen

            Path { path in
                // Top-left
                path.move(to: CGPoint(x: 0, y: l))
                path.addLine(to: CGPoint(x: 0, y: r))
                path.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: l, y: 0))

                // Top-right
                path.move(to: CGPoint(x: s.width - l, y: 0))
                path.addLine(to: CGPoint(x: s.width - r, y: 0))
                path.addQuadCurve(to: CGPoint(x: s.width, y: r), control: CGPoint(x: s.width, y: 0))
                path.addLine(to: CGPoint(x: s.width, y: l))

                // Bottom-left
                path.move(to: CGPoint(x: 0, y: s.height - l))
                path.addLine(to: CGPoint(x: 0, y: s.height - r))
                path.addQuadCurve(
                    to: CGPoint(x: r, y: s.height), control: CGPoint(x: 0, y: s.height))
                path.addLine(to: CGPoint(x: l, y: s.height))

                // Bottom-right
                path.move(to: CGPoint(x: s.width - l, y: s.height))
                path.addLine(to: CGPoint(x: s.width - r, y: s.height))
                path.addQuadCurve(
                    to: CGPoint(x: s.width, y: s.height - r),
                    control: CGPoint(x: s.width, y: s.height))
                path.addLine(to: CGPoint(x: s.width, y: s.height - l))
            }
            .stroke(color, style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
        }
    }
}
