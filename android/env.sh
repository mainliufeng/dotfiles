case "$(uname -s)" in
  Darwin)
    android_home="$HOME/Library/Android/sdk"
    ;;
  *)
    android_home="/opt/android-sdk"
    ;;
esac

if [ -d "$android_home" ]; then
  export ANDROID_HOME="$android_home"
  export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
fi
