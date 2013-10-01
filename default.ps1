properties { 
  $base_dir = resolve-path .  
  $nuget_bin = "$base_dir\tools\.nuget\nuget.exe"
  $7zip_bin = "$base_dir\tools\7zip\7za.exe"
  $project_dir = "$base_dir\UserVoice.Binding"  
  $sln_file = "$base_dir\UserVoice.Binding.sln"  
  $jar_dir = "$project_dir\jars"
  $config = "Release"  

  $android_sdk_dir = $env:ANDROID_SDK_HOME
  $android_library_dir = "$base_dir\uservoice-android-sdk\UserVoiceSDK"
}

Framework "4.0"

task default -depends Package

task Clean {  
  remove-item -force -recurse $project_dir\obj -ErrorAction SilentlyContinue
  remove-item -force -recurse $project_dir\bin -ErrorAction SilentlyContinue
  remove-item -force -recurse "$jar_dir\bin" -ErrorAction SilentlyContinue
  remove-item -force -recurse "$jar_dir\res" -ErrorAction SilentlyContinue
  remove-item -force "$jar_dir\*.zip" -ErrorAction SilentlyContinue
  remove-item -force "$jar_dir\*.jar" -ErrorAction SilentlyContinue  
}

task Compile -depends Clean,Copy-Jars {
    msbuild $sln_file /p:"Configuration=$config"
}

task Package -depends Compile{
    exec{
        & $nuget_bin pack "$project_dir\Package.nuspec"       
    }
}

task Copy-Jars -depends Clean,Test-Environment{
    Copy-Item -Force "$android_library_dir\libs\*.jar" "$jar_dir"
	Copy-Item -Recurse -Force "$android_library_dir\bin\*.jar" "$jar_dir"
    Copy-Item -Recurse -Force "$android_library_dir\bin" "$jar_dir"
    Copy-Item -Recurse -Force "$android_library_dir\res" "$jar_dir"
    
    # Eclipse is putting the drawables in a "crunch" folder which Xamarin Android isn't expecting
    Move-Item "$jar_dir\bin\res\crunch\*" "$jar_dir\bin\res\"
    Remove-Item "$jar_dir\bin\res\crunch"

    # Compress the binaries and resources into the library package zip
    exec{
        & $7zip_bin a -r "$jar_dir\library.zip" "$jar_dir\bin\"
        & $7zip_bin a -r "$jar_dir\library.zip" "$jar_dir\res\"
    }
    Remove-Item -recurse -force "$jar_dir\bin"
    Remove-Item -recurse -force "$jar_dir\res"
}

task Test-Environment{
    if(-not (Test-Path "$android_sdk_dir\tools")){        
        throw "A valid Android SDK path must be specified in the ANDROID_SDK_HOME environment variable"
    }

    if(-not (Test-Path "$android_library_dir")){        
        throw "Ensure the library is downloaded to: $android_library_dir"
    }

    if(-not (Test-Path "$android_library_dir\bin")){        
        throw "Please compile the library: $android_library_dir in eclipse before building this project"
    }    
}