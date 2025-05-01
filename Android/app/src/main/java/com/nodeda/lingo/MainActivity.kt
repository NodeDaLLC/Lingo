package com.nodeda.lingo

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.ui.graphics.Color
import android.os.Build
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import androidx.core.view.WindowCompat
import java.util.*

class MainActivity : ComponentActivity(), TextToSpeech.OnInitListener {
    private lateinit var speechRecognizer: SpeechRecognizer
    private lateinit var textToSpeech: TextToSpeech
    private var isListening = false
    private var spokenTextState = mutableStateOf("")
    private var isPaused = mutableStateOf(false)

    private val speechPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startListening()
        } else {
            Toast.makeText(this, "Permission required for speech recognition", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make system bars edge to edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        textToSpeech = TextToSpeech(this, this)

        setContent {
            val isDarkTheme = isSystemInDarkTheme()
            val dynamicColorEnabled = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
            val systemUiController = rememberSystemUiController()
            val useDarkIcons = !isDarkTheme

            DisposableEffect(systemUiController, useDarkIcons) {
                systemUiController.setSystemBarsColor(
                    color = Color.Transparent,
                    darkIcons = useDarkIcons
                )
                onDispose {}
            }

            MaterialTheme(
                colorScheme = when {
                    dynamicColorEnabled -> {
                        if (isDarkTheme) {
                            dynamicDarkColorScheme(LocalContext.current)
                        } else {
                            dynamicLightColorScheme(LocalContext.current)
                        }
                    }
                    isDarkTheme -> darkColorScheme()
                    else -> lightColorScheme()
                }
            ) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen(
                        onPauseResume = { togglePauseResume() },
                        onSpeakText = { text -> speakText(text) },
                        isListening = isListening,
                        isPaused = isPaused.value,
                        spokenText = spokenTextState.value
                    )
                }
            }
        }

        setupSpeechRecognizer()
        // Request permission and start listening when the app launches
        requestPermissionAndStart()
    }

    override fun onResume() {
        super.onResume()
        if (!isListening && !isPaused.value) {
            requestPermissionAndStart()
        }
    }

    override fun onPause() {
        super.onPause()
        stopListening()
    }

    private fun togglePauseResume() {
        isPaused.value = !isPaused.value
        if (isPaused.value) {
            stopListening()
        } else {
            startListening()
        }
    }

    private fun setupSpeechRecognizer() {
        speechRecognizer.setRecognitionListener(object : android.speech.RecognitionListener {
            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val spokenText = matches[0]
                    spokenTextState.value = spokenText
                    // Automatically start listening again if not paused
                    if (!isPaused.value) {
                        startListening()
                    }
                }
            }

            override fun onReadyForSpeech(params: Bundle?) {
                isListening = true
            }

            override fun onError(error: Int) {
                isListening = false
                // If there's an error, try to start listening again after a short delay if not paused
                if (!isPaused.value) {
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        if (!isFinishing) {
                            startListening()
                        }
                    }, 1000)
                }
            }

            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    spokenTextState.value = matches[0]
                }
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
    }

    private fun requestPermissionAndStart() {
        speechPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
    }

    private fun startListening() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }
        speechRecognizer.startListening(intent)
    }

    private fun stopListening() {
        speechRecognizer.stopListening()
        isListening = false
    }

    private fun speakText(text: String) {
        textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val result = textToSpeech.setLanguage(Locale.getDefault())
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Toast.makeText(this, "Language not supported", Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(this, "Text to Speech initialization failed", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        speechRecognizer.destroy()
        textToSpeech.stop()
        textToSpeech.shutdown()
    }
}

@Composable
fun MainScreen(
    onPauseResume: () -> Unit,
    onSpeakText: (String) -> Unit,
    isListening: Boolean,
    isPaused: Boolean,
    spokenText: String
) {
    var text by remember { mutableStateOf("") }
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Caption display area with top padding for notch and scrolling
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(top = 48.dp) // Extra padding for notch
        ) {
            Text(
                text = spokenText,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(scrollState)
                    .padding(8.dp)
            )
        }

        // Bottom section with input and buttons
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.ime),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Text input field
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                label = { Text("Type to speak") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.primary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                    focusedLabelColor = MaterialTheme.colorScheme.primary,
                    unfocusedLabelColor = MaterialTheme.colorScheme.onSurfaceVariant
                )
            )

            // Buttons row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                // Speak button
                Button(
                    onClick = { onSpeakText(text) },
                    enabled = text.isNotEmpty(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        contentColor = MaterialTheme.colorScheme.onPrimary
                    )
                ) {
                    Text("Speak")
                }

                // Pause/Resume button
                Button(
                    onClick = onPauseResume,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.secondary,
                        contentColor = MaterialTheme.colorScheme.onSecondary
                    )
                ) {
                    Text(if (isPaused) "Resume Captions" else "Pause Captions")
                }
            }
        }
    }
}