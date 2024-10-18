
import IronSource
import Foundation
import AdSupport
import UserMessagingPlatform
import AppTrackingTransparency

class LaunchViewController: UIViewController {
    // IDFA
    func requestIDFA() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            print("only notDetermined status.")
            return
        }
        
        ATTrackingManager.requestTrackingAuthorization { status in
            // do something
        }
    
    }

    // UMP
    func requestUMPConsent() {


        guard ATTrackingManager.trackingAuthorizationStatus == .authorized else {
            print("ATT not authorized")
            return
        }
        
        
        if UMPConsentInformation.sharedInstance.canRequestAds {
            print("already canRequestAds")
            return
        }

        var umpRequestParameter: UMPRequestParameters? = nil
#if DEBUG
        // テスト時は device Identifierを設定
        umpRequestParameter = UMPRequestParameters()
        let umpDebugSettings = UMPDebugSettings()
        umpDebugSettings.testDeviceIdentifiers = ["your device Identifier"]
        umpDebugSettings.geography = UMPDebugGeography.EEA
        umpRequestParameter?.debugSettings = umpDebugSettings
#endif
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: umpRequestParameter) { [weak self] error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                print(error)
                return
            }
            
            // フォームロード
            if UMPConsentInformation.sharedInstance.consentStatus == .required {
                UMPConsentForm.loadAndPresentIfRequired(from: self) { loadAndPresentError in
                    if let loadAndPresentError = loadAndPresentError {
                        print(loadAndPresentError)
                        return
                    }
                }
            }
        }
    }

    // init
    func initializeIronSource() {
        let ironSourceAppKey = "your ironSource appKey"
        // init
        IronSource.initWithAppKey(ironSourceAppKey, delegate: self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        requestIDFA()
        requestUMPConsent()
        initializeIronSource()
    }

}