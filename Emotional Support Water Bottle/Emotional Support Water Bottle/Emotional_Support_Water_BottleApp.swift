//
//  Emotional_Support_Water_BottleApp.swift
//  Emotional Support Water Bottle
//
//  Created by devian on 2026-04-28.
//

import SwiftUI
import SwiftData

@main
struct Emotional_Support_Water_BottleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HydrationEntry.self,
            UserPreferences.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // In-memory container can't fail (no filesystem I/O), but ModelContainer API
            // always declares throws. The app can't function without a container, so
            // force-try is appropriate here.
            return try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        }
    }()
    
    @State private var hydrationManager = HydrationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(hydrationManager)
                .task {
                    // Request notification permission silently
                    _ = await NotificationManager.shared.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
