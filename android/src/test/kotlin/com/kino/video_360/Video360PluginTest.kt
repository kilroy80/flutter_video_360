package com.kino.video_360

import kotlin.test.Test
import kotlin.test.assertNotNull

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class Video360PluginTest {
  @Test
  fun plugin_canBeCreated() {
    val plugin = Video360Plugin()
    assertNotNull(plugin)
  }
}
