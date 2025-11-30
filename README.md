# 🎵 Sound Bubble Notes

A playful Flutter app that lets you record short voice notes and visualize them as colorful, floating bubbles.  
Each voice note becomes a “bubble” that you can play, delete, archive, or interact with — turning your audio notes collection into a fun, visual notebook.

---

## 📚 Features

- **Record short voice notes (up to ~10 seconds)**  
  • Tap to start/stop or press-and-hold to record  
  • Simple recording UI indicator (e.g. pulsing dot)

- **Visual bubble representation**  
  • Each note appears as a bubble with random color and size (reflects duration)  
  • Bubble shows icon or timestamp  
  • Bubbles float with subtle animations for a playful UI

- **Bubble interactions**  
  • Tap to play the note  
  • Swipe right → delete (with fade/shrink animation)  
  • Swipe left → archive the note  
  • Long press → open options (Play, Delete, Archive)  

- **Local storage (offline)**  
  • Audio saved locally (device storage)  
  • Metadata (id, path, duration, date, archived flag) stored locally (file or simple DB)  
  • No backend — everything runs on the device  

- **Optional archived notes view**  
  • Separate screen or list for archived notes  

---

## 🛠 Getting Started

### Requirements

- Flutter stable  
- Permissions: Microphone (for recording), Storage (for saving files)  

### Setup & Run

```bash
git clone https://github.com/YJAM20/soundbubblenotes.git
cd soundbubblenotes
flutter pub get
flutter run
Usage
Grant microphone permission.

Press the record button to record a short note (max 10 seconds).

Note appears as a bubble.

Tap bubble → play, swipe → delete/archive, long-press → options.

🗂 Project Structure (recommended)
bash
Copy code
lib/
  main.dart
  models/
    note_model.dart
  services/
    audio_service.dart       # handles recording and playback
    storage_service.dart     # handles saving/loading metadata & file paths
  screens/
    home_screen.dart         # showing bubbles
    archived_screen.dart     # showing archived notes (if implemented)
  widgets/
    bubble_widget.dart       # UI for a bubble (color, size, interactions)
    recording_indicator.dart # optional UI for during-record
  utils/                     # helper functions (e.g. random color generator)
✅ Recommendations & TODOs (next steps)
Run flutter analyze and clean up warnings / unused imports

Add better error handling for permissions, file IO, playback failures

Optimize bubble animations for performance (especially when many bubbles)

Handle edge cases: long lists, app restart (reloading), storage permissions decline

Add unit/widget tests for core logic (audio service, storage service, note model)

📄 License
This project is open-source under the MIT License.

👤 Author
Yaman Jehad Muhanna
Flutter Developer & Software Engineering Student
GitHub: YJAM20
