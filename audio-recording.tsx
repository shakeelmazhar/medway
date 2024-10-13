import React, {useEffect} from 'react';
import {
  Alert,
  Button,
  NativeEventEmitter,
  NativeModules,
  PermissionsAndroid,
  Platform,
  View,
} from 'react-native';
import {check, PERMISSIONS, request, RESULTS} from 'react-native-permissions';

const {AudioChunkModule} = NativeModules;
const audioChunkEmitter = new NativeEventEmitter(AudioChunkModule);

const requestAudioPermissions = async () => {
  if (Platform.OS === 'android') {
    const permission = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
    );

    const storagePermission = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
    );

    return (
      permission === PermissionsAndroid.RESULTS.GRANTED &&
      storagePermission === PermissionsAndroid.RESULTS.GRANTED
    );
  } else {
    // For iOS, check and request permission
    const result = await check(PERMISSIONS.IOS.MICROPHONE);
    if (result === RESULTS.GRANTED) {
      return true;
    } else {
      const requestResult = await request(PERMISSIONS.IOS.MICROPHONE);
      return requestResult === RESULTS.GRANTED;
    }
  }
};

const AudioRecorder = () => {
  console.debug('AudioRecorder');
  useEffect(() => {
    const subscription = audioChunkEmitter.addListener(
      'AudioChunkCaptured',
      data => {
        console.log('Audio chunk captured:', data.filePath);
        Alert.alert('Audio chunk captured', data.filePath);
      },
    );

    return () => {
      subscription.remove();
    };
  }, []);

  const startRecording = async () => {
    const hasPermission = await requestAudioPermissions();
    if (hasPermission) {
      const fileName = `audio_${Date.now()}.m4a`; // Use appropriate file path
      AudioChunkModule.startRecording(fileName);
    } else {
      Alert.alert(
        'Permission Denied',
        'Microphone access is required to record audio.',
      );
    }
  };

  const stopRecording = () => {
    AudioChunkModule.stopRecording();
  };

  return (
    <View>
      <Button title="Start Recording" onPress={startRecording} />
      <Button title="Stop Recording" onPress={stopRecording} />
    </View>
  );
};

export default AudioRecorder;
