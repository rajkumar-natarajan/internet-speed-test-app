import React, { useState } from 'react';
import { SafeAreaView, View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const getServerUrl = (server) => {
  switch(server) {
    case 'speed.hetzner.de':
      return 'https://speed.hetzner.de/100MB.bin';
    case 'speedtest.dallas.linode.com':
      return 'https://speedtest.dallas.linode.com/100MB.bin';
    case 'speedtest.tokyo.linode.com':
      return 'https://speedtest.tokyo.linode.com/100MB.bin';
    default:
      return 'https://speed.hetzner.de/100MB.bin';
  }
};

const measureLatency = async (server) => {
  const times = [];
  for (let i = 0; i < 5; i++) {
    const start = Date.now();
    await fetch(getServerUrl(server), { 
      method: 'HEAD',
      timeout: 5000
    }).catch(() => {});
    const end = Date.now();
    times.push(end - start);
  }
  
  // Remove highest and lowest values
  times.sort((a, b) => a - b);
  times.pop();
  times.shift();
  
  // Calculate average and jitter
  const avg = times.reduce((a, b) => a + b, 0) / times.length;
  const jitter = times.reduce((a, b) => a + Math.abs(b - avg), 0) / times.length;
  
  return { latency: Math.round(avg), jitter: Math.round(jitter) };
};

const testSpeed = async (setDownload, setUpload, setTesting, setError, setProgress, setLatency, setJitter, selectedServer, setHistory) => {
  setTesting(true);
  setError(null);
  setProgress({ type: null, value: 0 });

  try {
    // Latency test
    setProgress({ type: 'latency', value: 0 });
    const { latency: pingResult, jitter: jitterResult } = await measureLatency(selectedServer);
    setLatency(pingResult);
    setJitter(jitterResult);
    setProgress({ type: 'latency', value: 100 });

    // Download speed test
    const serverUrl = getServerUrl(selectedServer);
    const start = Date.now();
    const response = await fetch(serverUrl, {
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

    // Save test results to history
    const result = {
      timestamp: Date.now(),
      download: downloadSpeed,
      upload: uploadSpeed,
      latency: pingResult,
      jitter: jitterResult,
      server: selectedServer
    };
    setHistory(prev => [...prev, result]);

  } catch (error) {
    setError(error.message);
  } finally {
    setTesting(false);
  }
};

export default function App() {
  const [download, setDownload] = useState(null);
  const [upload, setUpload] = useState(null);
  const [latency, setLatency] = useState(null);
  const [jitter, setJitter] = useState(null);
  const [testing, setTesting] = useState(false);
  const [error, setError] = useState(null);
  const [progress, setProgress] = useState({ type: null, value: 0 });
  const [history, setHistory] = useState([]);
  const [selectedServer, setSelectedServer] = useState('auto');
  
  const servers = {
    auto: 'Automatic (Closest Server)',
    'speed.hetzner.de': 'Hetzner (Germany)',
    'speedtest.dallas.linode.com': 'Linode (Dallas)',
    'speedtest.tokyo.linode.com': 'Linode (Tokyo)'
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Internet Speed Test</Text>
        
        <View style={styles.serverSelector}>
          <Text style={styles.label}>Test Server:</Text>
          {Object.entries(servers).map(([key, name]) => (
            <TouchableOpacity
              key={key}
              style={[
                styles.serverOption,
                selectedServer === key && styles.serverOptionSelected
              ]}
              onPress={() => setSelectedServer(key)}
            >
              <Text style={[
                styles.serverOptionText,
                selectedServer === key && styles.serverOptionTextSelected
              ]}>{name}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {testing ? (
          <View style={styles.progressContainer}>
            <Text style={styles.progressText}>
              {progress.type === 'latency' && 'Testing Latency...'}
              {progress.type === 'download' && 'Testing Download...'}
              {progress.type === 'upload' && 'Testing Upload...'}
            </Text>
            <View style={styles.progressBar}>
              <View style={[styles.progressFill, { width: `${Math.min(progress.value, 100)}%` }]} />
            </View>
            <Text style={styles.progressValue}>{progress.value.toFixed(1)}%</Text>
          </View>
        ) : (
          <TouchableOpacity
            style={styles.button}
            onPress={() => testSpeed(
              setDownload, 
              setUpload, 
              setTesting, 
              setError, 
              setProgress, 
              setLatency,
              setJitter,
              selectedServer,
              setHistory
            )}
          >
            <Text style={styles.buttonText}>Start Test</Text>
          </TouchableOpacity>
        )}
        
        {error && <Text style={styles.error}>{error}</Text>}
        
        <View style={styles.resultsContainer}>
          {latency && (
            <View style={styles.resultRow}>
              <Text style={styles.resultLabel}>Latency:</Text>
              <Text style={styles.resultValue}>{latency} ms</Text>
            </View>
          )}
          {jitter && (
            <View style={styles.resultRow}>
              <Text style={styles.resultLabel}>Jitter:</Text>
              <Text style={styles.resultValue}>{jitter} ms</Text>
            </View>
          )}
          {download && (
            <View style={styles.resultRow}>
              <Text style={styles.resultLabel}>Download:</Text>
              <Text style={styles.resultValue}>{download} MB/s</Text>
            </View>
          )}
          {upload && (
            <View style={styles.resultRow}>
              <Text style={styles.resultLabel}>Upload:</Text>
              <Text style={styles.resultValue}>{upload} MB/s</Text>
            </View>
          )}
        </View>

        {history.length > 0 && (
          <View style={styles.historyContainer}>
            <Text style={styles.historyTitle}>Test History</Text>
            {history.slice(-5).map((result) => (
              <View key={result.timestamp} style={styles.historyItem}>
                <Text style={styles.historyDate}>
                  {new Date(result.timestamp).toLocaleString()}
                </Text>
                <View style={styles.historyResults}>
                  <Text style={styles.historyText}>↓ {result.download} MB/s</Text>
                  <Text style={styles.historyText}>↑ {result.upload} MB/s</Text>
                  <Text style={styles.historyText}>📶 {result.latency} ms</Text>
                </View>
              </View>
            ))}
          </View>
        )}
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
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#007AFF',
  },
  serverSelector: {
    width: '100%',
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  serverOption: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  serverOptionSelected: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  serverOptionText: {
    fontSize: 14,
    color: '#333',
  },
  serverOptionTextSelected: {
    color: '#fff',
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
  resultsContainer: {
    width: '100%',
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  resultLabel: {
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  resultValue: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
  },
  historyContainer: {
    width: '100%',
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginTop: 20,
  },
  historyTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  historyItem: {
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  historyDate: {
    fontSize: 12,
    color: '#666',
    marginBottom: 5,
  },
  historyResults: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  historyText: {
    fontSize: 14,
    color: '#333',
  },
});
