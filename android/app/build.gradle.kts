plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase 구글 서비스를 위한 플러그인
    id("com.google.gms.google-services")
}

android {
    // 1. NDK 버전: jni 등 최신 플러그인 요구 사항에 맞춰 28 버전으로 고정
    ndkVersion = "28.2.13676358"

    namespace = "com.example.cook"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // 이전 버전 안드로이드 기기 지원을 위한 디슈가링 활성화
        isCoreLibraryDesugaringEnabled = true

        // 2. Java 버전을 17로 업그레이드 (최신 플러그인 및 경고 제거용)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // 3. Kotlin 대상 JVM도 자바 버전과 동일하게 17로 설정
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.cook"

        // 4. ML Kit 및 알림 기능을 위해 minSdk는 flutter.minSdkVersion을 따르되
        // 일반적으로 21 이상이 권장됩니다.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 배포 시에도 일단 디버그용 서명 설정을 사용 (필요 시 추후 수정)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Java 8+ API 사용을 위한 최신 desugar 라이브러리
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // 한국어 텍스트 인식을 위한 ML Kit 라이브러리
    implementation("com.google.mlkit:text-recognition-korean:16.0.0")
}

flutter {
    source = "../.."
}