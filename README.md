# [DOKU](https://mastbau-fn.github.io/inspector/doc/)

# Try [here](https://mastbau-fn.github.io/inspector/app/)

# inspector

inOffizielles Repo für die Mastbau FN GmBH Inspektions APP

## Getting Started

### Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Environment

create a .env file in the frontend dir containing a field `API_KEY=xxx`

and for signing a key.properties file in the android dir containing

```properties
storePassword=TODO
keyPassword=TODO
keyAlias=key0
storeFile=../keystore-mbg.jks
```

### Build

- `flutter pub run build_runner build --delete-conflicting-outputs` to run code gen (probably optional)
- `flutter build` {apk, web, ..}

### Sign

to build a signed release a key.properties file must be added in the frontend/android directory that consists of

```properties
storePassword=TODO(if the keystore wasnt changed these are the same passwords as used for the vm admin)
keyPassword=TODO
keyAlias=key0
storeFile=../keystore-mbg.jks
```
