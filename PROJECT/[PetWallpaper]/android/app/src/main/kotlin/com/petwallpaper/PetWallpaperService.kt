package com.petwallpaper.app

import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.abs
import kotlin.random.Random

class PetWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine = PetEngine()

    inner class PetEngine : Engine() {
        private val handler = Handler(Looper.getMainLooper())
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        private val bgPaint = Paint()

        // 고양이 픽셀아트 색상
        private val bodyColor = Color.rgb(255, 165, 80)
        private val stripeColor = Color.rgb(200, 100, 30)
        private val eyeColor = Color.rgb(60, 200, 80)
        private val noseColor = Color.rgb(255, 100, 120)

        private var petX = 400f
        private var petY = 800f
        private var velX = 2.5f
        private var velY = 1.5f
        private var screenW = 1080f
        private var screenH = 1920f
        private val petSize = 80f

        private var mood = "happy" // happy, hungry, sleeping, jumping
        private var frameCount = 0
        private var isVisible = true
        private var jumpVel = 0f
        private var isJumping = false
        private var moodTimer = 0

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (isVisible) {
                    update()
                    draw()
                }
                handler.postDelayed(this, 50) // 20fps
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            handler.post(drawRunnable)
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            screenW = width.toFloat()
            screenH = height.toFloat()
            petX = screenW / 2
            petY = screenH - 200f
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            handler.removeCallbacks(drawRunnable)
        }

        override fun onVisibilityChanged(visible: Boolean) {
            isVisible = visible
            if (visible) handler.post(drawRunnable)
            else handler.removeCallbacks(drawRunnable)
        }

        override fun onTouchEvent(event: MotionEvent) {
            if (event.action == MotionEvent.ACTION_DOWN) {
                val dx = abs(event.x - petX)
                val dy = abs(event.y - petY)
                if (dx < petSize * 2 && dy < petSize * 2) {
                    // 펫을 터치하면 점프!
                    isJumping = true
                    jumpVel = -18f
                    mood = "happy"
                    moodTimer = 60
                }
            }
        }

        private fun update() {
            frameCount++
            moodTimer--
            if (moodTimer <= 0) {
                mood = when (Random.nextInt(4)) {
                    0 -> "happy"
                    1 -> "hungry"
                    2 -> "sleeping"
                    else -> "happy"
                }
                moodTimer = 120 + Random.nextInt(180)
            }

            // 이동
            petX += velX
            petY += velY

            // 점프 물리
            if (isJumping) {
                petY += jumpVel
                jumpVel += 1.2f
                if (petY >= screenH - 200f) {
                    petY = screenH - 200f
                    isJumping = false
                    jumpVel = 0f
                }
            }

            // 벽에서 튕기기
            if (petX - petSize < 0) { petX = petSize; velX = abs(velX) }
            if (petX + petSize > screenW) { petX = screenW - petSize; velX = -abs(velX) }
            if (petY - petSize < 0) { petY = petSize; velY = abs(velY) }
            if (petY + petSize > screenH - 100f) { petY = screenH - 100f; velY = -abs(velY) }

            // 랜덤 방향 변경
            if (frameCount % 200 == 0) {
                velX = (Random.nextFloat() * 5 - 2.5f).coerceIn(-4f, 4f)
                velY = (Random.nextFloat() * 3 - 1.5f).coerceIn(-3f, 3f)
            }
        }

        private fun draw() {
            val holder = surfaceHolder
            var canvas: Canvas? = null
            try {
                canvas = holder.lockCanvas()
                canvas?.let { drawFrame(it) }
            } finally {
                if (canvas != null) holder.unlockCanvasAndPost(canvas)
            }
        }

        private fun drawFrame(canvas: Canvas) {
            // 배경 그라데이션
            val gradient = LinearGradient(
                0f, 0f, 0f, screenH,
                Color.rgb(15, 15, 35),
                Color.rgb(30, 30, 60),
                Shader.TileMode.CLAMP
            )
            bgPaint.shader = gradient
            canvas.drawRect(0f, 0f, screenW, screenH, bgPaint)

            // 별 그리기
            paint.color = Color.argb(180, 255, 255, 255)
            paint.style = Paint.Style.FILL
            for (i in 0 until 50) {
                val sx = (i * 137.5f + frameCount * 0.1f) % screenW
                val sy = (i * 73.3f) % (screenH * 0.6f)
                val sr = if (i % 3 == 0) 2f else 1f
                canvas.drawCircle(sx, sy, sr, paint)
            }

            // 고양이 그리기 (픽셀아트 스타일)
            drawPixelCat(canvas, petX, petY)

            // 감정 표시
            drawMoodBubble(canvas, petX, petY - petSize - 30f)
        }

        private fun drawPixelCat(canvas: Canvas, x: Float, y: Float) {
            val s = petSize * 0.6f
            val walkOffset = if (mood != "sleeping") (frameCount % 8) * 4f else 0f

            // 몸통
            paint.color = bodyColor
            paint.style = Paint.Style.FILL
            canvas.drawRoundRect(x - s, y - s * 1.2f, x + s, y + s * 0.8f, s * 0.3f, s * 0.3f, paint)

            // 줄무늬
            paint.color = stripeColor
            paint.strokeWidth = s * 0.15f
            paint.style = Paint.Style.STROKE
            canvas.drawLine(x - s * 0.3f, y - s * 0.8f, x - s * 0.3f, y + s * 0.2f, paint)
            canvas.drawLine(x + s * 0.3f, y - s * 0.8f, x + s * 0.3f, y + s * 0.2f, paint)

            // 머리
            paint.color = bodyColor
            paint.style = Paint.Style.FILL
            canvas.drawCircle(x, y - s * 1.5f, s * 0.9f, paint)

            // 귀
            val earPath = Path().apply {
                moveTo(x - s * 0.7f, y - s * 2.1f)
                lineTo(x - s * 1.1f, y - s * 2.8f)
                lineTo(x - s * 0.2f, y - s * 2.1f)
                close()
            }
            canvas.drawPath(earPath, paint)
            val earPath2 = Path().apply {
                moveTo(x + s * 0.7f, y - s * 2.1f)
                lineTo(x + s * 1.1f, y - s * 2.8f)
                lineTo(x + s * 0.2f, y - s * 2.1f)
                close()
            }
            canvas.drawPath(earPath2, paint)

            // 눈 (자는 중이면 감은 눈)
            if (mood == "sleeping") {
                paint.color = Color.rgb(30, 30, 30)
                paint.strokeWidth = s * 0.2f
                paint.style = Paint.Style.STROKE
                canvas.drawLine(x - s * 0.45f, y - s * 1.5f, x - s * 0.15f, y - s * 1.5f, paint)
                canvas.drawLine(x + s * 0.15f, y - s * 1.5f, x + s * 0.45f, y - s * 1.5f, paint)
            } else {
                paint.color = eyeColor
                paint.style = Paint.Style.FILL
                canvas.drawCircle(x - s * 0.3f, y - s * 1.55f, s * 0.22f, paint)
                canvas.drawCircle(x + s * 0.3f, y - s * 1.55f, s * 0.22f, paint)
                paint.color = Color.BLACK
                canvas.drawCircle(x - s * 0.28f, y - s * 1.55f, s * 0.12f, paint)
                canvas.drawCircle(x + s * 0.28f, y - s * 1.55f, s * 0.12f, paint)
            }

            // 코
            paint.color = noseColor
            paint.style = Paint.Style.FILL
            canvas.drawCircle(x, y - s * 1.3f, s * 0.12f, paint)

            // 꼬리
            paint.color = bodyColor
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = s * 0.25f
            paint.strokeCap = Paint.Cap.ROUND
            val tailPath = Path().apply {
                moveTo(x + s * 0.8f, y + s * 0.5f)
                cubicTo(
                    x + s * 1.8f, y + s * 0.2f,
                    x + s * 2.0f, y - s * 0.8f,
                    x + s * 1.5f, y - s * 1.2f
                )
            }
            canvas.drawPath(tailPath, paint)

            // 다리 (걷는 애니메이션)
            paint.color = bodyColor
            paint.style = Paint.Style.FILL
            if (mood != "sleeping") {
                val legOffset1 = kotlin.math.sin(walkOffset * 0.3f) * s * 0.3f
                val legOffset2 = kotlin.math.cos(walkOffset * 0.3f) * s * 0.3f
                canvas.drawRoundRect(x - s * 0.5f, y + s * 0.6f, x - s * 0.1f, y + s * 0.9f + legOffset1, s * 0.1f, s * 0.1f, paint)
                canvas.drawRoundRect(x + s * 0.1f, y + s * 0.6f, x + s * 0.5f, y + s * 0.9f + legOffset2, s * 0.1f, s * 0.1f, paint)
            }
        }

        private fun drawMoodBubble(canvas: Canvas, x: Float, y: Float) {
            val emoji = when (mood) {
                "happy" -> "♡"
                "hungry" -> "..."
                "sleeping" -> "zzz"
                else -> "♡"
            }
            paint.color = Color.argb(200, 255, 255, 255)
            paint.style = Paint.Style.FILL
            canvas.drawRoundRect(x - 30f, y - 25f, x + 30f, y + 5f, 15f, 15f, paint)
            paint.color = Color.rgb(80, 80, 80)
            paint.textSize = 22f
            paint.textAlign = Paint.Align.CENTER
            paint.style = Paint.Style.FILL
            canvas.drawText(emoji, x, y - 5f, paint)
        }
    }
}
