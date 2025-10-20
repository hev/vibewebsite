import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import posthog from 'posthog-js'

// Initialize PostHog

if (typeof window !== 'undefined' && import.meta.env.VITE_POSTHOG_KEY) {
  try {
    posthog.init(import.meta.env.VITE_POSTHOG_KEY, {
      api_host: import.meta.env.VITE_POSTHOG_HOST || 'https://us.i.posthog.com',
      autocapture: true,
      capture_pageview: true,
      capture_pageleave: true
    })
  } catch (error) {
    console.error('PostHog initialization failed:', error)
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
