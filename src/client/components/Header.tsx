import { useState, FormEvent } from 'react'

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
      } else {
        setMessage({ type: 'error', text: data.error || 'Failed to subscribe' })
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
                placeholder="🎃 join halloween pop up"
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
