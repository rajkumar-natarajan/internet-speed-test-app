import React, { useState } from 'react';
import { SafeAreaView, View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const testSpeed = async (setDownload, setUpload, setTesting, setError, setProgress) => {
  setTesting(true);
  setError(null);
  setProgress({ type: null, value: 0 });

  try {
    // Download speed test
    const start = Date.now();
    const response = await fetch('https://speed.hetzner.de/100MB.bin', {
      timeout: 30000 // 30 second timeout
    }).catch(error => {
      throw new Error(`Download test failed: ${error.message}`);
    });

    const contentLength = response.headers.get('content-length');
    const reader = response.body.getReader();
    let receivedLength = 0;

    while (true) {
      const {done, value} = await reader.read();
      if (done) break;
      receivedLength += value.length;
      setProgress({
        type: 'download',
        value: (receivedLength / contentLength) * 100
      });
    }

    const end = Date.now();
    const downloadSpeed = (receivedLength / 1024 / 1024 / ((end - start) / 1000)).toFixed(2); // MB/s
    setDownload(downloadSpeed);
    setProgress({ type: 'download', value: 100 });

    // Upload speed test with actual data
    setProgress({ type: 'upload', value: 0 });
    const uploadData = new Array(1024 * 1024).fill('X').join(''); // 1MB of data
    const uploadStart = Date.now();
    
    const uploadResponse = await fetch('https://httpbin.org/post', {
      method: 'POST',
      body: uploadData,
      timeout: 30000
    }).catch(error => {
      throw new Error(`Upload test failed: ${error.message}`);
    });

    if (!uploadResponse.ok) {
      throw new Error(`Upload failed with status: ${uploadResponse.status}`);
    }

    const uploadEnd = Date.now();
    const uploadSpeed = (1 / ((uploadEnd - uploadStart) / 1000)).toFixed(2); // MB/s (1MB file)
    setUpload(uploadSpeed);
    setProgress({ type: 'upload', value: 100 });

  } catch (error) {
    setError(error.message);
  } finally {
    setTesting(false);
  }
};

export default function App() {
  const [download, setDownload] = useState(null);
  const [upload, setUpload] = useState(null);
  const [testing, setTesting] = useState(false);
  const [error, setError] = useState(null);
  const [progress, setProgress] = useState({ type: null, value: 0 });

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Internet Speed Test</Text>
        {testing ? (
          <View style={styles.progressContainer}>
            <Text style={styles.progressText}>
              {progress.type === 'download' ? 'Testing Download...' : 'Testing Upload...'}
            </Text>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: `${Math.min(progress.value, 100)}%` }]} />
            </View>
            <Text style={styles.progressValue}>{progress.value.toFixed(1)}%</Text>
          </View>
        ) : (
          <TouchableOpacity
            style={styles.button}
            onPress={() => testSpeed(setDownload, setUpload, setTesting, setError, setProgress)}
          >
            <Text style={styles.buttonText}>Start Test</Text>
          </TouchableOpacity>
        )}
        {error && <Text style={styles.error}>{error}</Text>}
        {download && (
          <Text style={styles.result}>Download Speed: {download} MB/s</Text>
        )}
        {upload && <Text style={styles.result}>Upload Speed: {upload} MB/s</Text>}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f2f2f2',
  },
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 30,
    color: '#007AFF',
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 5,
    marginBottom: 20,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  result: {
    fontSize: 18,
    marginBottom: 10,
    color: '#333',
  },
  error: {
    color: 'red',
    fontSize: 16,
    marginBottom: 10,
  },
  progressContainer: {
    width: '100%',
    alignItems: 'center',
    marginBottom: 20,
  },
  progressText: {
    fontSize: 16,
    marginBottom: 10,
    color: '#333',
  },
  progressBar: {
    width: '100%',
    height: 20,
    backgroundColor: '#f0f0f0',
    borderRadius: 10,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#007AFF',
  },
  progressValue: {
    fontSize: 14,
    marginTop: 5,
    color: '#666',
  },
});
