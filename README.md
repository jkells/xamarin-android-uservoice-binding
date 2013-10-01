# Xamarin.Android.UserVoice.Binding #

## About ##

This project provides Xamarin Android bindings for the UserVoice Android SDK
 

## Build instructions ##
 * Place Xamarin.Android.Support.v4-r18.dll into the ThirdParty folder. It can be downloaded from the Xamarin component store.
 * Set the `ANDROID_SDK_HOME` environment variable to the root of your Android SDK folder.
 * Download the user voice sdk into the uservoice-android-sdk folder (link below)
 * Build the java library in eclipse.  ( See below )
 * Run psake.cmd

## Building the library in eclipse
 * In eclipse. File -> New -> Project
 * Android project from existing code
 * Select `uservoice-android-sdk\UserVoiceSDK`
 * Press finish. The project will build automatically
 * bin and res folders should have been created. 

## Links ##
* [UserVoice SDK](https://github.com/uservoice/uservoice-android-sdk)
