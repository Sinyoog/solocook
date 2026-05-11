plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cook"
    compileSdk = flutter.compileSdkVersion

    // 1. NDK 버전 업데이트 (에러 메시지가 요구한 버전)
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        // 2. Java 버전을 17로 업그레이드 (최신 플러그인 권장 사항)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // 3. Kotlin 대상 JVM도 17로 맞춤
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.cook"
        // 4. ML Kit 및 알림 기능을 위해 minSdk를 최소 21 이상으로 명시하는 것이 안전합니다.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 최신 desugar 라이브러리 사용
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.mlkit:text-recognition-korean:16.0.0")
}

flutter {
    source = "../.."
}
