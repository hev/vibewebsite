import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'

dotenv.config()

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 8081

app.use(cors())
app.use(express.json())

// API Routes
app.post('/api/subscribe', async (req, res) => {
  try {
    const { email } = req.body

    if (!email) {
      return res.status(400).json({ error: 'Email is required' })
    }

    const LOOPS_API_KEY = process.env.LOOPS_API_KEY

    if (!LOOPS_API_KEY) {
      console.error('LOOPS_API_KEY not configured')
      return res.status(500).json({ error: 'Server configuration error' })
    }

    // Call Loops API
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

    const data = await response.json() as { message?: string }

    if (!response.ok) {
      console.error('Loops API error:', data)
      // Check if it's a duplicate email error
      if (data.message?.includes('already in your audience')) {
        return res.status(200).json({ success: true, message: '👻 Your spirit is already on our list...' })
      }
      return res.status(response.status).json({ error: data.message || 'Failed to subscribe' })
    }

    res.json({ success: true, message: '🎃 Invite request received! We\'ll summon you soon...' })
  } catch (error) {
    console.error('Subscribe error:', error)
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
