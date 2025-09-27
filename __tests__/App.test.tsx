/**
 * @format
 */

import * as React from 'react';
import { create, act } from 'react-test-renderer';
import App from '../App';

test('renders correctly', async () => {
  await act(async () => {
    create(<App />);
  });
});
