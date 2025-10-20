import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

dotenv.config()

// Log environment status
console.log('🔧 Server starting...')
console.log('  Environment:', process.env.NODE_ENV || 'development')
console.log('  PostHog:', process.env.VITE_POSTHOG_KEY ? 'configured' : 'not configured')
console.log('  Loops:', process.env.LOOPS_API_KEY ? 'configured' : 'not configured')

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 8081

app.use(cors())
app.use(express.json())

// API Routes
app.post('/api/subscribe', async (req, res) => {
  const startTime = Date.now()
  const { email } = req.body

  console.log(`📧 Loops API: Email subscription attempt for ${email}`)

  try {
    if (!email) {
      console.log('❌ Loops API: No email provided')
      return res.status(400).json({ error: 'Email is required' })
    }

    const LOOPS_API_KEY = process.env.LOOPS_API_KEY

    if (!LOOPS_API_KEY) {
      console.error('❌ Loops API: LOOPS_API_KEY not configured')
      return res.status(500).json({ error: 'Server configuration error' })
    }

    // Call Loops API
    console.log('🔄 Loops API: Sending request to Loops...')
    const response = await fetch('https://app.loops.so/api/v1/contacts/create', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${LOOPS_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email,
        mailingLists: {}
      })
    })

    const data = await response.json() as { success?: boolean, message?: string }
    const duration = Date.now() - startTime
    
    console.log(`📊 Loops API: Response received (${duration}ms)`, { 
      status: response.status, 
      ok: response.ok, 
      data: data 
    })

    // Check if it's a duplicate email error (even with 200 status)
    if (data.message?.includes('already in your audience')) {
      console.log('✅ Loops API: Email already in audience - treating as success')
      console.log('📊 PostHog: Client should now send email_subscribed event (existing user)')
      return res.status(200).json({ success: true, message: '👻 Your spirit is already on our list...' })
    }

    if (!response.ok) {
      console.error('❌ Loops API: Error response:', data)
      return res.status(response.status).json({ error: data.message || 'Failed to subscribe' })
    }

    // Check if Loops returned success: false even with 200 status
    if (data.success === false) {
      console.error('❌ Loops API: Returned success: false:', data)
      return res.status(400).json({ error: data.message || 'Failed to subscribe' })
    }

    console.log('✅ Loops API: Email successfully added to audience')
    console.log('📊 PostHog: Client should now send email_subscribed event')
    res.json({ success: true, message: '🎃 Invite request received! We\'ll summon you soon...' })
  } catch (error) {
    const duration = Date.now() - startTime
    console.error(`❌ Loops API: Error after ${duration}ms:`, error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Serve static files in production
if (process.env.NODE_ENV === 'production') {
  const clientPath = path.join(__dirname, '../../client')
  app.use(express.static(clientPath))

  app.get('*', (_req, res) => {
    res.sendFile(path.join(clientPath, 'index.html'))
  })
}

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
