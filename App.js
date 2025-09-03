import React, { useState } from 'react';
import { SafeAreaView, View, Text, Button, ActivityIndicator, StyleSheet } from 'react-native';

const testSpeed = async (setDownload, setUpload, setTesting) => {
  setTesting(true);
  // Download speed test
  const start = Date.now();
  await fetch('https://speed.hetzner.de/100MB.bin');
  const end = Date.now();
  const downloadSpeed = (100 / ((end - start) / 1000)).toFixed(2); // MB/s
  setDownload(downloadSpeed);

  // Upload speed test (simulated)
  const uploadStart = Date.now();
  await fetch('https://httpbin.org/post', { method: 'POST', body: 'speedtest' });
  const uploadEnd = Date.now();
  const uploadSpeed = (0.001 / ((uploadEnd - uploadStart) / 1000)).toFixed(2); // MB/s (simulated)
  setUpload(uploadSpeed);

  setTesting(false);
};

export default function App() {
  const [download, setDownload] = useState(null);
  const [upload, setUpload] = useState(null);
  const [testing, setTesting] = useState(false);

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Internet Speed Test</Text>
      <Button title={testing ? 'Testing...' : 'Start Test'} onPress={() => testSpeed(setDownload, setUpload, setTesting)} disabled={testing} />
      {testing && <ActivityIndicator size="large" color="#007AFF" style={{ margin: 20 }} />}
      {download && (
        <View style={styles.resultBox}>
          <Text style={styles.result}>Download Speed: {download} MB/s</Text>
          <Text style={styles.result}>Upload Speed: {upload} MB/s</Text>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f2f2f2',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 30,
    color: '#007AFF',
  },
  resultBox: {
    marginTop: 30,
    padding: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 5,
    shadowOffset: { width: 0, height: 2 },
  },
  result: {
    fontSize: 20,
    marginBottom: 10,
    color: '#333',
  },
});
