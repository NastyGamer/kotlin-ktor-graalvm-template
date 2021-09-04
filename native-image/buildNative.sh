export NATIVE_IMAGE=~/.jdks/graalvm-ce-java16-21.2.0/bin/native-image
export FAT_JAR=../target/sample-artifact-1.0-SNAPSHOT.jar
export REFLECTION_JSON=./reflections.json
export MAIN_CLASS=sample.Main
export APP_NAME=graal-client

set -e
set -x

if [ ! -f $NATIVE_IMAGE ]; then
  echo "Fat jar doesn't exist. Attempting to build it."
  cd .. && mvn package
fi

if [ ! -f $REFLECTION_JSON ]; then
  echo "Reflections json does not exist."
  exit 1
fi

if [ ! -f $NATIVE_IMAGE ]; then
  echo "native-image binary does not exist."
  exit 1
fi

$NATIVE_IMAGE \
  --verbose \
  --no-fallback \
  -esa \
  --enable-all-security-services \
  --report-unsupported-elements-at-runtime \
  --install-exit-handlers \
  --allow-incomplete-classpath \
  --initialize-at-build-time=io.ktor,kotlinx,kotlin,org.slf4j \
  -H:+ReportUnsupportedElementsAtRuntime \
  -H:+ReportExceptionStackTraces \
  -H:ReflectionConfigurationFiles=$REFLECTION_JSON \
  -cp $FAT_JAR \
  -H:Class=$MAIN_CLASS \
  -H:Name=$APP_NAME
