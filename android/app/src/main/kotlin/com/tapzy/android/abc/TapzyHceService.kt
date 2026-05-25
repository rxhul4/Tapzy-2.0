package com.tapzy.android.abc

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.content.Context
import android.util.Log
import java.nio.charset.Charset

class TapzyHceService : HostApduService() {

    companion object {
        private const val TAG = "TapzyHceService"

        // AID for NFC Forum Type 4 Tag
        private val APDU_SELECT_AID = byteArrayOf(
            0x00.toByte(), 0xA4.toByte(), 0x04.toByte(), 0x00.toByte(), 0x07.toByte(),
            0xD2.toByte(), 0x76.toByte(), 0x00.toByte(), 0x00.toByte(), 0x85.toByte(),
            0x01.toByte(), 0x01.toByte(), 0x00.toByte()
        )

        // File Select command for CC File (E1 03)
        private val APDU_SELECT_CC = byteArrayOf(
            0x00.toByte(), 0xA4.toByte(), 0x00.toByte(), 0x0C.toByte(), 0x02.toByte(),
            0xE1.toByte(), 0x03.toByte()
        )

        // File Select command for NDEF File (E1 04)
        private val APDU_SELECT_NDEF = byteArrayOf(
            0x00.toByte(), 0xA4.toByte(), 0x00.toByte(), 0x0C.toByte(), 0x02.toByte(),
            0xE1.toByte(), 0x04.toByte()
        )

        // Status bytes
        private val STATUS_SUCCESS = byteArrayOf(0x90.toByte(), 0x00.toByte())
        private val STATUS_FAILED = byteArrayOf(0x6F.toByte(), 0x00.toByte())

        // CC File data
        private val CC_FILE = byteArrayOf(
            0x00.toByte(), 0x0F.toByte(), // CC Length
            0x20.toByte(),                // Version 2.0
            0x00.toByte(), 0x7F.toByte(), // Max Read Size
            0x00.toByte(), 0x7F.toByte(), // Max Write Size
            0x04.toByte(), 0x06.toByte(), // NDEF TLV
            0xE1.toByte(), 0x04.toByte(), // NDEF File ID
            0x04.toByte(), 0x00.toByte(), // Max NDEF Size (1024 bytes)
            0x00.toByte(),                // Read access
            0xFF.toByte()                 // Write access (write restricted)
        )
    }

    private var selectedFile: SelectedFile = SelectedFile.NONE

    private enum class SelectedFile {
        NONE, CC, NDEF
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null) return STATUS_FAILED

        Log.d(TAG, "Command APDU received: " + toHex(commandApdu))

        // Check if SELECT BY AID
        if (commandApdu.contentEquals(APDU_SELECT_AID)) {
            selectedFile = SelectedFile.NONE
            Log.d(TAG, "AID selected")
            return STATUS_SUCCESS
        }

        // Check if SELECT CC
        if (commandApdu.contentEquals(APDU_SELECT_CC)) {
            selectedFile = SelectedFile.CC
            Log.d(TAG, "CC file selected")
            return STATUS_SUCCESS
        }

        // Check if SELECT NDEF
        if (commandApdu.contentEquals(APDU_SELECT_NDEF)) {
            selectedFile = SelectedFile.NDEF
            Log.d(TAG, "NDEF file selected")
            return STATUS_SUCCESS
        }

        // Check if READ BINARY
        if (commandApdu.size >= 4 && commandApdu[0] == 0x00.toByte() && commandApdu[1] == 0xB0.toByte()) {
            val offset = (((commandApdu[2].toInt() and 0xFF) shl 8) or (commandApdu[3].toInt() and 0xFF))
            
            // Length is optional in READ BINARY. We read a reasonable chunk or the whole file.
            var length = 0
            if (commandApdu.size > 4) {
                length = commandApdu[4].toInt() and 0xFF
            }

            Log.d(TAG, "Read Binary requested: selectedFile=$selectedFile, offset=$offset, length=$length")

            return when (selectedFile) {
                SelectedFile.CC -> {
                    if (offset >= CC_FILE.size) return STATUS_FAILED
                    val bytesToCopy = if (length == 0 || offset + length > CC_FILE.size) CC_FILE.size - offset else length
                    val result = ByteArray(bytesToCopy + 2)
                    System.arraycopy(CC_FILE, offset, result, 0, bytesToCopy)
                    result[bytesToCopy] = 0x90.toByte()
                    result[bytesToCopy + 1] = 0x00.toByte()
                    result
                }
                SelectedFile.NDEF -> {
                    val ndefMessageBytes = getNdefMessageBytes()
                    if (offset >= ndefMessageBytes.size) return STATUS_FAILED
                    val bytesToCopy = if (length == 0 || offset + length > ndefMessageBytes.size) ndefMessageBytes.size - offset else length
                    val result = ByteArray(bytesToCopy + 2)
                    System.arraycopy(ndefMessageBytes, offset, result, 0, bytesToCopy)
                    result[bytesToCopy] = 0x90.toByte()
                    result[bytesToCopy + 1] = 0x00.toByte()
                    result
                }
                else -> STATUS_FAILED
            }
        }

        return STATUS_FAILED
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "Deactivated: reason=$reason")
        selectedFile = SelectedFile.NONE
    }

    private fun getNdefMessageBytes(): ByteArray {
        // Read active URL from SharedPreferences
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        // Flutter SharedPreferences keys are prefixed with "flutter."
        val url = prefs.getString("flutter.active_nfc_url", "") ?: ""
        
        Log.d(TAG, "Active NFC URL from shared preferences: $url")
        
        val urlToUse = if (url.trim().isEmpty()) {
            "https://profile.tapzy.in" // Default fallback
        } else {
            url
        }

        // Build NDEF Record for URI:
        var prefix = 0x00.toByte()
        var uriText = urlToUse
        if (urlToUse.startsWith("https://www.")) {
            prefix = 0x02.toByte() // 0x02: "https://www."
            uriText = urlToUse.substring(12)
        } else if (urlToUse.startsWith("http://www.")) {
            prefix = 0x01.toByte() // 0x01: "http://www."
            uriText = urlToUse.substring(11)
        } else if (urlToUse.startsWith("https://")) {
            prefix = 0x04.toByte() // 0x04: "https://"
            uriText = urlToUse.substring(8)
        } else if (urlToUse.startsWith("http://")) {
            prefix = 0x03.toByte() // 0x03: "http://"
            uriText = urlToUse.substring(7)
        }

        val uriBytes = uriText.toByteArray(Charset.forName("UTF-8"))
        val payloadLen = uriBytes.size + 1
        
        val recordBytes = ByteArray(4 + payloadLen)
        recordBytes[0] = 0xD1.toByte() // Well Known NDEF record, short record
        recordBytes[1] = 0x01.toByte() // Type Length = 1 byte
        recordBytes[2] = payloadLen.toByte() // Payload length
        recordBytes[3] = 0x55.toByte() // 'U' type (URI)
        recordBytes[4] = prefix // URI Prefix
        System.arraycopy(uriBytes, 0, recordBytes, 5, uriBytes.size)

        // Type 4 NDEF container requires a 2-byte length field prefixing the NDEF message:
        val containerBytes = ByteArray(2 + recordBytes.size)
        containerBytes[0] = ((recordBytes.size ushr 8) and 0xFF).toByte()
        containerBytes[1] = (recordBytes.size and 0xFF).toByte()
        System.arraycopy(recordBytes, 0, containerBytes, 2, recordBytes.size)

        return containerBytes
    }

    private fun toHex(bytes: ByteArray): String {
        val sb = StringBuilder()
        for (b in bytes) {
            sb.append(String.format("%02X ", b))
        }
        return sb.toString().trim()
    }
}
