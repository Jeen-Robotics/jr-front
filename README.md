# Jeen Robotics Front

## Pre-requisites

Create `.env` file in the project root:

```env
GOOGLE_MAPS_API_KEY=<API-KEY>
```

## Generate bindings

```bash
dart run ffigen --config <path/to/target/ffigen.yaml>
```

## Build Android APK

```bash
flutter build apk --split-per-abi --release
```
