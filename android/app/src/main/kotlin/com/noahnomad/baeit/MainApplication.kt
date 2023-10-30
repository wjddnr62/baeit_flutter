package com.noahnomad.baeit

import co.ab180.airbridge.flutter.AirbridgeFlutter
import io.flutter.app.FlutterApplication

class MainApplication: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        AirbridgeFlutter.init(this, "baeit", "b029ed6772624709b26afb36be661a4e")
    }
}