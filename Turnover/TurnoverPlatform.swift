//
//  TurnoverPlatform.swift
//  Turnover
//
//  Created by Codex on 4/1/26.
//

import CoreLocation
import Foundation
import UIKit

final class CoreLocationRunTrackingService: NSObject, RunTrackingService, RunPlatformStatusProviding {
    var latestSnapshot: RunTrackingSnapshot?
    var onSnapshot: ((RunTrackingSnapshot) -> Void)?
    var onStatusChange: ((RunPlatformStatus) -> Void)?

    private let locationManager: CLLocationManager

    private var tickTimer: Timer?
    private var sessionStartDate: Date?
    private var pauseStartedAt: Date?
    private var accumulatedPausedSeconds: TimeInterval = 0
    private var settings: RunSettings?
    private var isTrackingActive = false

    private var lastLocation: CLLocation?
    private var routeLocations: [CLLocation] = []
    private var totalDistanceMeters: Double = 0
    private var totalElevationGainMeters: Double = 0
    private var latestPaceSecondsPerKilometer: Double?

    override init() {
        let locationManager = CLLocationManager()
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = false

        self.locationManager = locationManager
        super.init()

        locationManager.delegate = self
    }

    deinit {
        tickTimer?.invalidate()
    }

    func currentPlatformStatus() -> RunPlatformStatus {
        RunPlatformStatus(
            trackingAuthorization: authorizationState,
            trackingAvailability: trackingAvailabilityState,
            heartRateAvailability: .unavailable
        )
    }

    func refreshPlatformStatus() {
        onStatusChange?(currentPlatformStatus())
    }

    func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            assertionFailure("UIApplication.openSettingsURLString produced an invalid URL")
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    func start(settings: RunSettings, startedAt: Date) {
        stop()

        self.settings = settings
        sessionStartDate = startedAt
        pauseStartedAt = nil
        accumulatedPausedSeconds = 0
        isTrackingActive = true
        lastLocation = nil
        routeLocations = []
        totalDistanceMeters = 0
        totalElevationGainMeters = 0
        latestPaceSecondsPerKilometer = nil

        if supportsBackgroundLocation {
            locationManager.allowsBackgroundLocationUpdates = true
        }

        publishSnapshot(referenceDate: startedAt)
        refreshPlatformStatus()
        requestAuthorizationIfNeeded()
        updateLocationUpdates()
        startTicking()
    }

    func pause() {
        guard isTrackingActive, pauseStartedAt == nil else { return }

        pauseStartedAt = Date()
        stopTicking()
        updateLocationUpdates()
    }

    func resume() {
        guard isTrackingActive, let pauseStartedAt else { return }

        accumulatedPausedSeconds += Date().timeIntervalSince(pauseStartedAt)
        self.pauseStartedAt = nil
        updateLocationUpdates()
        startTicking()
    }

    func stop() {
        isTrackingActive = false
        stopTicking()
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        pauseStartedAt = nil
    }

    private var authorizationState: PlatformAuthorizationState {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }

    private var trackingAvailabilityState: PlatformAvailabilityState {
        CLLocationManager.locationServicesEnabled() ? .available : .unavailable
    }

    private var supportsBackgroundLocation: Bool {
        let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
        return backgroundModes?.contains("location") == true
    }

    private func requestAuthorizationIfNeeded() {
        guard trackingAvailabilityState == .available else { return }
        guard locationManager.authorizationStatus == .notDetermined else { return }

        locationManager.requestWhenInUseAuthorization()
    }

    private func updateLocationUpdates() {
        guard isTrackingActive, pauseStartedAt == nil else {
            locationManager.stopUpdatingLocation()
            return
        }

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            locationManager.stopUpdatingLocation()
        @unknown default:
            locationManager.stopUpdatingLocation()
        }
    }

    private func startTicking() {
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.publishSnapshot(referenceDate: Date())
        }
    }

    private func stopTicking() {
        tickTimer?.invalidate()
        tickTimer = nil
    }

    private func publishSnapshot(referenceDate: Date) {
        guard let sessionStartDate else { return }

        let snapshot = RunTrackingSnapshot(
            elapsedSeconds: max(Int(referenceDate.timeIntervalSince(sessionStartDate)), 0),
            movingSeconds: movingSeconds(referenceDate: referenceDate),
            distanceMeters: totalDistanceMeters,
            currentPaceSecondsPerSplit: convertedPace(secondsPerKilometer: latestPaceSecondsPerKilometer),
            averagePaceSecondsPerSplit: averagePaceSecondsPerSplit(referenceDate: referenceDate),
            heartRate: nil,
            elevationGainMeters: totalElevationGainMeters,
            routeShape: routeShape
        )

        latestSnapshot = snapshot
        onSnapshot?(snapshot)
    }

    private func movingSeconds(referenceDate: Date) -> Int {
        guard let sessionStartDate else { return 0 }

        let activePauseSeconds = if let pauseStartedAt {
            accumulatedPausedSeconds + referenceDate.timeIntervalSince(pauseStartedAt)
        } else {
            accumulatedPausedSeconds
        }

        return max(Int(referenceDate.timeIntervalSince(sessionStartDate) - activePauseSeconds), 0)
    }

    private func averagePaceSecondsPerSplit(referenceDate: Date) -> Double? {
        guard totalDistanceMeters > 0 else { return nil }

        let secondsPerKilometer = Double(movingSeconds(referenceDate: referenceDate)) * 1_000.0 / totalDistanceMeters
        return convertedPace(secondsPerKilometer: secondsPerKilometer)
    }

    private func convertedPace(secondsPerKilometer: Double?) -> Double? {
        guard let secondsPerKilometer, let settings else { return nil }

        switch settings.splitUnit {
        case .kilometer:
            return secondsPerKilometer
        case .mile:
            return secondsPerKilometer * 1.60934
        }
    }

    private var routeShape: [Double] {
        let limit = 120
        let points = routeLocations.count > limit
            ? stride(from: 0, to: routeLocations.count, by: max(routeLocations.count / limit, 1)).map { routeLocations[$0] }
            : routeLocations

        let latitudes = points.map(\.coordinate.latitude)

        guard let minLatitude = latitudes.min(), let maxLatitude = latitudes.max() else {
            return []
        }

        let latitudeRange = maxLatitude - minLatitude
        guard latitudeRange > 0.000_001 else {
            return Array(repeating: 0.5, count: latitudes.count)
        }

        return latitudes.map { latitude in
            (latitude - minLatitude) / latitudeRange
        }
    }

    private func record(location: CLLocation) {
        guard location.horizontalAccuracy >= 0 else { return }

        guard let lastLocation else {
            routeLocations.append(location)
            lastLocation = location
            return
        }

        let timeInterval = location.timestamp.timeIntervalSince(lastLocation.timestamp)
        guard timeInterval > 0 else { return }

        let segmentDistance = location.distance(from: lastLocation)
        let segmentSpeed = segmentDistance / timeInterval
        guard segmentDistance.isFinite, segmentDistance >= 0, segmentDistance < 250, segmentSpeed < 12 else { return }

        totalDistanceMeters += segmentDistance
        totalElevationGainMeters += max(location.altitude - lastLocation.altitude, 0)

        if location.speed > 0.5 {
            latestPaceSecondsPerKilometer = 1_000.0 / location.speed
        } else if segmentSpeed > 0.5 {
            latestPaceSecondsPerKilometer = 1_000.0 / segmentSpeed
        }

        routeLocations.append(location)
        self.lastLocation = location
    }
}

extension CoreLocationRunTrackingService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshPlatformStatus()
        updateLocationUpdates()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTrackingActive, pauseStartedAt == nil else { return }

        let validLocations = locations.filter { location in
            location.horizontalAccuracy >= 0 && location.timestamp.timeIntervalSinceNow > -60
        }

        guard !validLocations.isEmpty else { return }

        for location in validLocations {
            record(location: location)
        }

        publishSnapshot(referenceDate: validLocations.last?.timestamp ?? Date())
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        refreshPlatformStatus()

        if let locationError = error as? CLError, locationError.code == .locationUnknown {
            return
        }

        assertionFailure("Core Location run tracking failed: \(error.localizedDescription)")
    }
}
