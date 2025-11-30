# 🎵 Sound Bubble Notes  
A playful, lightweight Flutter app that turns short voice notes into floating, animated bubbles.  
Every voice note becomes a visual object that you can tap, play, delete, or archive — combining audio recording with a fun, interactive UI.

Perfect as a creative experiment, portfolio piece, or minimal personal audio notebook.

---

## ✨ Features

### 🎙️ **Record Short Voice Notes**
- Tap or press-and-hold to record.
- Maximum duration ~10 seconds for quick memo-style notes.
- Smooth recording indicator with subtle animations.
- Safe recording behavior: handles permissions, device audio availability, and edge cases.

### 🔊 **Local Audio Playback**
- Notes are saved locally as audio files in the app directory.
- Each bubble knows its file path and metadata.
- Playback uses isolated `AudioPlayer` instances for clean handling.
- Pre-play checks ensure the audio file exists (avoiding “Loading interrupted”).

### 🫧 **Bubble-Based UI**
Each saved note appears as a bubble with:
- Randomized color from a curated palette.
- Size proportional to duration.
- Soft floating animation.
- Timestamp or mic icon label.

Bubble interactions:
- **Tap:** Play audio note  
- **Swipe Right:** Delete (with shrink/fade animation)  
- **Swipe Left:** Archive  
- **Long Press:** Options menu (Play, Delete, Archive)

### 📦 **Local Storage**
- Audio files stored using `path_provider` inside `ApplicationDocumentsDirectory`
- Metadata stored locally (JSON or lightweight storage)
- On delete or archive, file paths and metadata stay consistent
- Handles permission logic (Android microphone + storage)

### 🗂 **Archived Notes Screen**
- Separate view for archived notes
- Reversible or permanent delete behavior (configurable)

---

## 📂 Project Structure

A clean, maintainable folder layout used across production Flutter apps:

lib/
main.dart
models/
note_model.dart # Voice note metadata (path, duration, timestamp, archived flag)

services/
audio_service.dart # Recording + playback logic
storage_service.dart # File + metadata persistence

screens/
home_screen.dart # Bubble interface + main interactions
archived_screen.dart # Archived/removed notes

widgets/
bubble_widget.dart # Visual UI of a single bubble
record_button.dart # Recording UI + animation
recording_indicator.dart # Optional pulsing UI

utils/
color_generator.dart # Controlled random bubble colors
bubble_positioner.dart # Randomized placement logic

yaml
Copy code

This separation keeps UI clean and logic reusable.

---

## 🚀 Getting Started

### 🔧 Installation

```bash
git clone https://github.com/YJAM20/soundbubblenotes.git
cd soundbubblenotes
flutter pub get
flutter run
📱 Supported Platforms
Android ✔

iOS ✔ (with microphone permission updates)

Web ❌ (audio recording not supported natively here)

🔐 Permissions
Android: Add to AndroidManifest.xml
xml
Copy code
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
iOS: Add to Info.plist
xml
Copy code
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone to record short notes.</string>
⚙️ Implementation Highlights
✔ Safe Audio Handling
Ensures recorder is fully stopped before creating the file.

Adds a small stabilization delay to avoid corrupted output.

Uses separate AudioPlayer instances per playback to prevent “interrupted loading”.

✔ File Reliability
Before playing a note:

dart
Copy code
if (!File(path).existsSync()) {
  print("Cannot play: file missing");
  return;
}
✔ Clean Animations
Uses AnimatedPositioned, AnimatedOpacity, and Tween-based movements.

Avoids unnecessary rebuilds inside the animation loop.

✔ Clean State + Resource Management
All Controllers and Players properly disposed.

Bubble deletion deletes audio file safely.

Archiving moves bubble metadata without UI redraw storms.

🧪 TODO (Future Enhancements)
Add waveform preview inside each bubble

Add bubble drag interactions

Allow renaming notes

Add theme switch (light/dark)

Add search/filter functionality

Implement haptic feedback

Add multi-bubble physics (gravity/spring animation)

Add export/import notes

Add onboarding tutorial page

📸 Screenshots (coming soon)
Add UI previews once the design stabilizes.

🧑‍💻 Author
Yaman Jehad Muhanna
Flutter Developer | Software Engineering Student
GitHub: YJAM20

📄 License
This project is open-source and available under the MIT License.
