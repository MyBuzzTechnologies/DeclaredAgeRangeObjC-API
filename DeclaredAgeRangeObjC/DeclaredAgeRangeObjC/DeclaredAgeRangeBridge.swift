//
//  DeclaredAgeRangeBridge.swift
//  DeclaredAgeRangeObjC
//
//  Created by Chris Pimlott on 18/12/2025.
//

import Foundation
import UIKit
import DeclaredAgeRange
import os.log

@available(iOS 26.0, *)
@objcMembers
public class DeclaredAgeDeclarations: NSObject {
    @objc static public let none: Int = 0
    @objc static public let selfDeclared: Int = 1
    @objc static public let guardianDeclared: Int = 2
    @objc static public let checkedByOtherMethod: Int = 3
    @objc static public let guardianCheckedByOtherMethod: Int = 4
    @objc static public let governmentIDChecked: Int = 5
    @objc static public let guardianGovernmentIDChecked: Int = 6
    @objc static public let paymentChecked: Int = 7
    @objc static public let guardianPaymentChecked: Int = 8
}

@available(iOS 26.0, *)
@objcMembers
public class DeclaredAgeRangeResponse: NSObject {
    @objc public var resultCode: Int = 0
    @objc public var sharingDeclined: Bool = false
    @objc public var lowerBound: Int = 0
    @objc public var upperBound: Int = 0
    @objc public var ageRangeDeclaration: Int = 0
    @objc public var communicationLimits: Bool = false
    @objc public var significantAppChangeApprovalRequired: Bool = false
    @objc public var isEligibleForAgeFeatures: Bool = false
    
    static private func ageDeclarationToInt(_ ageDeclaration: AgeRangeService.AgeRangeDeclaration?) -> Int {
        switch ageDeclaration {
        case .selfDeclared:
            return DeclaredAgeDeclarations.selfDeclared
        case .guardianDeclared:
            return DeclaredAgeDeclarations.guardianDeclared
        case .checkedByOtherMethod:
            return DeclaredAgeDeclarations.checkedByOtherMethod
        case .guardianCheckedByOtherMethod:
            return DeclaredAgeDeclarations.guardianCheckedByOtherMethod
        case .governmentIDChecked:
            return DeclaredAgeDeclarations.governmentIDChecked
        case .guardianGovernmentIDChecked:
            return DeclaredAgeDeclarations.guardianGovernmentIDChecked
        case .paymentChecked:
            return DeclaredAgeDeclarations.paymentChecked
        case .guardianPaymentChecked:
            return DeclaredAgeDeclarations.guardianPaymentChecked
        case .none:
            return DeclaredAgeDeclarations.none;
        @unknown default:
            return DeclaredAgeDeclarations.none;
        }
    }
    
    static public func fromDARResponse(_ response: AgeRangeService.Response) -> DeclaredAgeRangeResponse {
        let res = DeclaredAgeRangeResponse()
        switch response {
        case .declinedSharing:
            res.resultCode = 0;
            res.sharingDeclined = true
        case .sharing(let range):
            res.resultCode = 0;
            res.sharingDeclined = false
            if let lower = range.lowerBound {
                res.lowerBound = Int(lower)
            }
            if let upper = range.upperBound {
                res.upperBound = Int(upper)
            }
            res.ageRangeDeclaration = ageDeclarationToInt(range.ageRangeDeclaration)
            res.communicationLimits = range.activeParentalControls.contains(.communicationLimits) == true
            res.significantAppChangeApprovalRequired = range.activeParentalControls.contains(.significantAppChangeApprovalRequired)
        @unknown default:
            res.resultCode = -3;
        }
        return res
    }
}

@available(iOS 26.0, *)
@objcMembers
public final class DeclaredAgeRangeBridge: NSObject {
        
    public static func fetchAgeRange(minimumAge: Int, maximumAge: Int = 0, vc: UIViewController, completion: @Sendable @escaping (DeclaredAgeRangeResponse?, NSError?) -> Void) {
        #if canImport(DeclaredAgeRange)
        Task {
            let appLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "fetchAgeRange")
            do {
                os_log("Running fetchAgeRange(%ld, %ld)", log: appLog, type: .info, minimumAge, maximumAge)
                
                let minAge = minimumAge
                var maxAge = maximumAge
                
                // Calling the iOS 26 Swift-only function
                if (maxAge < minAge) {
                    maxAge = minAge
                }
                
                let response = try await AgeRangeService.shared.requestAgeRange(ageGates: minAge, maxAge, in: vc)
                let darResponse = DeclaredAgeRangeResponse.fromDARResponse(response)
                
                os_log("fetchAgeRange: responded %ld", log: appLog, type: .info, darResponse.resultCode)
                
                if #available(iOS 26.2, *) {
                    darResponse.isEligibleForAgeFeatures = try await AgeRangeService.shared.isEligibleForAgeFeatures
                    if (darResponse.isEligibleForAgeFeatures) {
                        os_log("fetchAgeRange: isEligibleForAgeFeatures YES", log: appLog, type: .info)
                    } else {
                        os_log("fetchAgeRange: isEligibleForAgeFeatures NO", log: appLog, type: .info)
                    }
                }
                
                // Assuming result has a description or raw value
                DispatchQueue.main.async {
                    completion(darResponse, nil)
                }
            } catch AgeRangeService.Error.notAvailable {
                os_log("fetchAgeRange: NotAvailable exception", log: appLog, type: .error)
                //The device isn’t ready (e.g., no Apple ID signed in). Handle gracefully by keeping the feature disabled.
                let darResponse = DeclaredAgeRangeResponse()
                darResponse.resultCode = -1
               // No age range provided.
                DispatchQueue.main.async {
                    completion(darResponse, NSError.init(domain: "Service not available", code: darResponse.resultCode))
                }
            } catch AgeRangeService.Error.invalidRequest {
                os_log("fetchAgeRange: InvalidRequest exception", log: appLog, type: .error)
                //Your code is asking for an invalid range (e.g., not at least 2 years wide)
                let darResponse = DeclaredAgeRangeResponse()
                darResponse.resultCode = -2
                
                DispatchQueue.main.async {
                    completion(nil, NSError.init(domain: "Invalid request", code: darResponse.resultCode))
                }
            } catch {
                os_log("fetchAgeRange: Exception %@", log: appLog, type: .error, (error as NSError).localizedDescription)
                
                DispatchQueue.main.async {
                    completion(nil, error as NSError)
                }
            }
        }
        #endif
    }
}

