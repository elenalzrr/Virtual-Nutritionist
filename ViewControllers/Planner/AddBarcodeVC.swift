import UIKit
import Toast
import AVFoundation

class AddBarcodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // Variabile și proprietăți necesare
    let captureSession = AVCaptureSession()
    let metadataOutput = AVCaptureMetadataOutput()
    let device = AVCaptureDevice.default(for: .video)
    var flashIsOn = false
    var dbFood = DBManagerFood()
    weak var delegate: AddBarcodeVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraCapture()
        setupUI()
        
        // Adăugare gestură de atingere pentru focalizare
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
               view.addGestureRecognizer(tapGesture)
        
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let touchPoint = gesture.location(in: view)
            
            guard let device = device else { return }
            
            do {
                try device.lockForConfiguration()
                
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    device.focusPointOfInterest = touchPoint
                }
                
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                    device.exposurePointOfInterest = touchPoint
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Nu s-a putut seta focalizarea camerei")
            }
        }
    func setupCameraCapture() {
            guard let captureDevice = device else {
                print("Nu se poate obține dispozitivul de captură al camerei.")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                } else {
                    print("Nu se poate adăuga intrarea la sesiunea de captură.")
                    return
                }
            } catch {
                print("Eroare la crearea obiectului AVCaptureInput: \(error.localizedDescription)")
                return
            }
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
            } else {
                print("Nu se poate adăuga ieșirea la sesiunea de captură.")
                return
            }
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code39, .code128, .qr]
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }

    
    var lastScannedBarcode: String?
    var isBarcodeScanningEnabled = true

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { continue }
            guard let stringValue = readableObject.stringValue else { continue }
            
            print(stringValue)
            delegate?.didScanBarcode(value: stringValue)
            if !isBarcodeScanningEnabled {
                // Scanarea codurilor de bare este dezactivată
                return
            }

            if lastScannedBarcode == stringValue {
                // Codul de bare curent este identic cu cel precedent, deci nu se face nimic
                continue
            }


                // Codul de bare a fost găsit în baza de date

                // Dezactivăm scanarea codurilor de bare
                isBarcodeScanningEnabled = false

                // Dezactivăm flash-ul
                disableFlash()


            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let createFoodVC = storyboard.instantiateViewController(withIdentifier: "CreateFoodVC") as? CreateFoodVC {
                createFoodVC.bc = stringValue
             
            }
            
            if let adminreviewfood = storyboard.instantiateViewController(withIdentifier: "reviewFood") as? CreateFoodVC {
                adminreviewfood.bc = stringValue
             
            }
            
            
            self.dismiss(animated: true, completion: nil)
            lastScannedBarcode = stringValue
        }
    }


    
    func toggleFlash() {
        guard let device = device else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if flashIsOn {
                    device.torchMode = .off
                    flashIsOn = false
                } else {
                    device.torchMode = .on
                    flashIsOn = true
                }
                device.unlockForConfiguration()
            } catch {
                print("Nu s-a putut activa/dezactiva lanterna")
            }
        } else {
            print("Dispozitivul nu are lanternă")
        }
    }
    func setupUI() {
        // Creare buton pentru activarea lanternei
        let toggleFlashButton = UIButton(type: .system)
        toggleFlashButton.setTitle("Toggle Flash", for: .normal)
        toggleFlashButton.addTarget(self, action: #selector(toggleFlashButtonTapped), for: .touchUpInside)
        toggleFlashButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Adăugare buton în view
        view.addSubview(toggleFlashButton)
        
        // Constrângeri pentru poziționarea butonului
        NSLayoutConstraint.activate([
            toggleFlashButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleFlashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        
    }

    @objc func toggleFlashButtonTapped() {
        toggleFlash()
    }
    func disableFlash() {
        guard flashIsOn else { return }  // Verificăm dacă flash-ul este deja dezactivat
        
        toggleFlash()  // Apelăm metoda toggleFlash pentru a inversa starea flash-ului și a-l dezactiva
    }
}

protocol AddBarcodeVCDelegate: class {
    func didScanBarcode(value: String)
}
