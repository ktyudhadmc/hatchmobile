package com.appdmc.hatchery

import android.app.PendingIntent
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Bridges to [PackageInstaller] so an app update can be installed without the
 * OS's install-confirmation prompt — but only when this app is the device's
 * Device Owner (Android Enterprise provisioning), the one condition under
 * which the platform allows a non-system app to skip that prompt. When it
 * isn't, [silentInstall] fails and the Dart side falls back to the normal
 * "hand the APK to the OS installer" flow.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.appdmc.hatchery/silent_install"

    private var pendingResult: MethodChannel.Result? = null
    private var installReceiver: BroadcastReceiver? = null
    private var installAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDeviceOwner" -> result.success(isDeviceOwner())
                    "canInstallUpdates" -> result.success(canInstallUpdates())
                    "openInstallUpdatesSettings" -> {
                        openInstallUpdatesSettings()
                        result.success(null)
                    }
                    "silentInstall" -> {
                        val apkPath = call.argument<String>("apkPath")
                        if (apkPath.isNullOrEmpty()) {
                            result.error("bad_args", "apkPath is required", null)
                        } else {
                            silentInstall(apkPath, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isDeviceOwner(): Boolean {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        return dpm.isDeviceOwnerApp(packageName)
    }

    /**
     * Whether the OS will let this app install an APK without routing
     * through Settings first. Below Android 8 (O) every app could install
     * packages once [REQUEST_INSTALL_PACKAGES] was granted at install time,
     * so this is always true there; from O onward it's a separate,
     * per-app toggle the user has to flip themselves.
     */
    private fun canInstallUpdates(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    /** Opens the system screen where the user flips that per-app toggle on. */
    private fun openInstallUpdatesSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
            data = Uri.parse("package:$packageName")
        }
        startActivity(intent)
    }

    private fun silentInstall(apkPath: String, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "An install is already in progress", null)
            return
        }

        val installer = packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            params.setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
        }

        try {
            val sessionId = installer.createSession(params)
            installer.openSession(sessionId).use { session ->
                File(apkPath).inputStream().use { input ->
                    session.openWrite("hatchmobile_update", 0, -1).use { output ->
                        input.copyTo(output)
                        session.fsync(output)
                    }
                }

                pendingResult = result
                val action = "$packageName.SILENT_INSTALL_STATUS.$sessionId"
                installAction = action
                registerInstallReceiver(action)

                val statusIntent = Intent(action).setPackage(packageName)
                val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
                val pendingIntent = PendingIntent.getBroadcast(this, sessionId, statusIntent, flags)
                session.commit(pendingIntent.intentSender)
            }
        } catch (e: Exception) {
            pendingResult = null
            unregisterInstallReceiver()
            result.error("install_failed", e.message, null)
        }
    }

    private fun registerInstallReceiver(action: String) {
        unregisterInstallReceiver()
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(
                    PackageInstaller.EXTRA_STATUS,
                    PackageInstaller.STATUS_FAILURE,
                )
                val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
                val callbackResult = pendingResult
                pendingResult = null
                unregisterInstallReceiver()

                when (status) {
                    PackageInstaller.STATUS_SUCCESS -> callbackResult?.success(true)
                    else -> callbackResult?.error(
                        "install_failed",
                        message ?: "Install failed with status $status",
                        status,
                    )
                }
            }
        }
        installReceiver = receiver
        val filter = IntentFilter(action)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
    }

    private fun unregisterInstallReceiver() {
        installReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
                // Already unregistered — fine.
            }
        }
        installReceiver = null
        installAction = null
    }

    override fun onDestroy() {
        unregisterInstallReceiver()
        super.onDestroy()
    }
}
