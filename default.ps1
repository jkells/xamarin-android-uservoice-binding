properties { 
  $base_dir = resolve-path .  
  $nuget_bin = "$base_dir\.nuget\nuget.exe"
  $project_dir = "$base_dir\UserVoice.Binding"  
  $sln_file = "$base_dir\UserVoice.Binding.sln"  
  $jar_dir = "$project_dir\jars"
  $config = "Release"  

  $android_sdk_dir = $env:ANDROID_SDK_HOME
  $android_library_dir = "$base_dir\uservoice-android-sdk"
  $android_library_build_dir = "$android_library_dir\UserVoiceSDK\build\outputs\aar"
}

Framework "4.0"

task default -depends Clean,Package

task Clean {  
  remove-item -force -recurse $project_dir\obj -ErrorAction SilentlyContinue
  remove-item -force -recurse $project_dir\bin -ErrorAction SilentlyContinue  
  remove-item -force "$jar_dir\*.aar" -ErrorAction SilentlyContinue
  remove-item -force -recurse "$android_library_dir\UserVoiceSDK\build" -ErrorAction SilentlyContinue  
}

task Compile -depends Copy-Jars {
    msbuild $sln_file /p:"Configuration=$config"
}

task Package -depends Compile{
    exec{
        & $nuget_bin pack "$project_dir\Package.nuspec"       
    }
}

task Copy-Jars -depends Build-Java-Library{
    Copy-Item -Force "$android_library_build_dir\*.aar" "$jar_dir"
}

task Test-Environment{
    if(-not (Test-Path "$android_sdk_dir\tools")){        
        throw "A valid Android SDK path must be specified in the ANDROID_SDK_HOME environment variable"
    }

    if(-not (Test-Path "$android_library_dir\UserVoiceSDK")){        
        throw "Ensure the library is downloaded to: $android_library_dir"
    }
}

task Build-Java-Library -depends Test-Environment{
    & "$env:ANDROID_SDK_HOME\tools\android" update lib-project --path "$android_library_dir\UserVoiceSDK" --target android-21
    & "$env:ANDROID_SDK_HOME\tools\android" update project --path "$android_library_dir\UVDemo" --target android-21
     
    #cp -Force $android_library_dir\UserVoiceSDK\local.properties $android_library_dir
    #cp -Force $base_dir\nolint-build.gradle $android_library_dir\UserVoiceSDK\build.gradle

    pushd    
    cd "$android_library_dir\UserVoiceSDK"
    .\gradlew.bat assembleRelease
    popd
}