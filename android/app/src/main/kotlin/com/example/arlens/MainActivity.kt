package com.example.arlens

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import org.opencv.core.MatOfPoint


class MainActivity : FlutterActivity() {
    private val CHANNEL = "corner_detection_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize OpenCV
        if (!OpenCVLoader.initDebug()) {
            // TODO: Handle failure to initialize OpenCV
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "detectCorners") {
                val imageBytes: ByteArray? = call.argument("imageBytes")
                if (imageBytes == null) {
                    result.error("NO_IMAGE", "No image data received", null)
                    return@setMethodCallHandler
                }
                val corners = detectCorners(imageBytes)
                result.success(corners)
            }
        }
    }

    private fun detectCorners(imageBytes: ByteArray): List<List<Int>> {
        // Convert image bytes to a Bitmap
        val bmp: Bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
        // Convert Bitmap to OpenCV Mat
        val mat = Mat()
        Utils.bitmapToMat(bmp, mat)

        // Convert to grayscale
        val grayMat = Mat()
        Imgproc.cvtColor(mat, grayMat, Imgproc.COLOR_RGBA2GRAY)
        Imgproc.GaussianBlur(grayMat, grayMat, Size(7.0, 7.0), 1.5)

        // Detect corners using Shi-Tomasi
        val maxCorners = 4
        val qualityLevel = 0.04
        val minDistance = 30.0
        val cornersMat = Mat()

        Imgproc.goodFeaturesToTrack(
            grayMat, cornersMat,
            maxCorners, qualityLevel, minDistance
        )

        // Convert result to List<List<Int>> for Flutter
        val result = mutableListOf<List<Int>>()
        for (i in 0 until cornersMat.rows()) {
            val data = cornersMat.get(i, 0)
            if (data != null && data.size >= 2) {
                val x = data[0].toInt()
                val y = data[1].toInt()
                result.add(listOf(x, y))
            }
        }

        return result
    }
}
