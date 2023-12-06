#include <jni.h>
#include "mylibrary.h"

extern "C" {

JNIEXPORT jstring JNICALL
Java_com_nativeaddondemo_MyLibraryWrapper_nativeGreet(JNIEnv *env, jobject thiz, jstring jName) {
    const char *name = env->GetStringUTFChars(jName, nullptr);
    std::string result = greet(std::string(name));
    env->ReleaseStringUTFChars(jName, name);
    return env->NewStringUTF(result.c_str());
}

JNIEXPORT jint JNICALL
Java_com_nativeaddondemo_MyLibraryWrapper_nativeAdd(JNIEnv *env, jobject thiz, jint a, jint b) {
    return add(a, b);
}

JNIEXPORT jstring JNICALL
Java_com_nativeaddondemo_MyLibraryWrapper_nativeReadFileContent(JNIEnv *env, jobject thiz, jstring jFilename) {
    const char *filename = env->GetStringUTFChars(jFilename, nullptr);
    std::string result = readFileContent(filename);
    env->ReleaseStringUTFChars(jFilename, filename);
    return env->NewStringUTF(result.c_str());
}

}