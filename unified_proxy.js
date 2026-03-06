#!/usr/bin/env node

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.argv[2] || process.env.PORT || 8000;

app.use((req, res, next) => {
  console.log(`${new Date().toLocaleTimeString()} [${req.method}] ${req.path}`);
  next();
});

app.use('/api', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: (path) => `/api${path}`,
  onError: (err, req, res) => {
    console.error('API Proxy Error:', err.message);
    res.status(502).json({ error: 'Backend service unavailable' });
  }
}));

app.use('/dashboard', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: (path) => `/dashboard${path}`,
  onError: (err, req, res) => {
    console.error('Dashboard Proxy Error:', err.message);
    res.status(502).json({ error: 'Dashboard service unavailable' });
  }
}));

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    services: {
      backend: 'http://localhost:5000',
      frontend: 'http://localhost:8080',
      proxy: `http://localhost:${PORT}`
    }
  });
});

app.use('/', createProxyMiddleware({
  target: 'http://localhost:8080',
  changeOrigin: true,
  ws: true,
  onError: (err, req, res) => {
    console.error('Frontend Proxy Error:', err.message);
    res.status(502).send('Frontend service unavailable on port 8080');
  }
}));

app.listen(PORT, 'localhost', () => {
  console.log(`Unified Proxy listening on http://localhost:${PORT}`);
});

process.on('SIGINT', () => {
  console.log('\nProxy server stopped');
  process.exit(0);
});
