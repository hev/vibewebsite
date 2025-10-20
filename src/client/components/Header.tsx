import { useState, FormEvent } from 'react'
import posthog from 'posthog-js'

function Header() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null)

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setMessage(null)

    try {
      const response = await fetch('/api/subscribe', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email })
      })

      const data = await response.json()

      if (response.ok) {
        setMessage({ type: 'success', text: data.message || 'Successfully subscribed!' })
        setEmail('')
        
        // Track signup event
        if (typeof posthog !== 'undefined') {
          try {
            console.log('📊 PostHog: Sending email_subscribed event for', email)
            
            posthog.identify(email, {
              email: email,
              signup_date: new Date().toISOString(),
              source: 'header_form',
              production: import.meta.env.VITE_PRODUCTION === 'true'
            })
            
            const eventData = {
              email: email,
              timestamp: new Date().toISOString(),
              page_url: window.location.href,
              page_title: document.title,
              is_existing_user: data.message?.includes('already in your audience') || false,
              loops_message: data.message,
              source: 'header_form',
              success: true,
              production: import.meta.env.VITE_PRODUCTION === 'true'
            }
            
            posthog.capture('email_subscribed', eventData)
            console.log('✅ PostHog: email_subscribed event sent successfully')
          } catch (error) {
            console.error('❌ PostHog tracking error:', error)
          }
        } else {
          console.error('❌ PostHog: Not available for email tracking')
        }
      } else {
        setMessage({ type: 'error', text: data.error || 'Failed to subscribe' })
        
        // Track failed signup attempt
        if (typeof posthog !== 'undefined') {
          try {
            console.log('📊 PostHog: Sending email_subscribe_failed event for', email)
            
            const eventData = {
              email: email,
              error: data.error || 'Unknown error',
              timestamp: new Date().toISOString(),
              page_url: window.location.href,
              page_title: document.title,
              source: 'header_form',
              success: false,
              production: import.meta.env.VITE_PRODUCTION === 'true'
            }
            
            posthog.capture('email_subscribe_failed', eventData)
            console.log('✅ PostHog: email_subscribe_failed event sent successfully')
          } catch (error) {
            console.error('❌ PostHog tracking error:', error)
          }
        } else {
          console.error('❌ PostHog: Not available for failed email tracking')
        }
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Network error. Please try again.' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <header>
      <div className="container">
        <div className="header-content">
          <div className="logo">
            <span className="logo-icon">✓<span className="cursor"></span></span>
            <span>vibe check</span>
          </div>
          <div>
            <form className="header-cta" onSubmit={handleSubmit}>
              <input
                type="email"
                className="header-input"
                placeholder="🎃 join the halloween pop up"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={loading}
                required
              />
              <button type="submit" className="header-btn" disabled={loading}>
                {loading ? 'Subscribing...' : 'Request Invite'}
              </button>
            </form>
            {message && (
              <div className={`header-message ${message.type}`}>
                {message.text}
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}

export default Header
