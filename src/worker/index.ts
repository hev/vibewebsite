/**
 * Cloudflare Worker for Vibe Check
 * Handles API requests and serves static assets
 */

export interface Env {
  LOOPS_API_KEY: string
  ASSETS: Fetcher
}

interface SubscribeRequest {
  email: string
}

interface LoopsResponse {
  message?: string
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url)

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    }

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: corsHeaders,
      })
    }

    // API endpoint: POST /api/subscribe
    if (url.pathname === '/api/subscribe' && request.method === 'POST') {
      try {
        const body = await request.json() as SubscribeRequest

        if (!body.email) {
          return new Response(
            JSON.stringify({ error: 'Email is required' }),
            {
              status: 400,
              headers: {
                'Content-Type': 'application/json',
                ...corsHeaders,
              },
            }
          )
        }

        const LOOPS_API_KEY = env.LOOPS_API_KEY

        if (!LOOPS_API_KEY) {
          console.error('LOOPS_API_KEY not configured')
          return new Response(
            JSON.stringify({ error: 'Server configuration error' }),
            {
              status: 500,
              headers: {
                'Content-Type': 'application/json',
                ...corsHeaders,
              },
            }
          )
        }

        // Call Loops API
        const loopsResponse = await fetch('https://app.loops.so/api/v1/contacts/create', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${LOOPS_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            email: body.email,
            mailingLists: {},
          }),
        })

        const data = await loopsResponse.json() as LoopsResponse

        if (!loopsResponse.ok) {
          console.error('Loops API error:', data)
          // Check if it's a duplicate email error
          if (data.message?.includes('already in your audience')) {
            return new Response(
              JSON.stringify({
                success: true,
                message: '👻 Your spirit is already on our list...'
              }),
              {
                status: 200,
                headers: {
                  'Content-Type': 'application/json',
                  ...corsHeaders,
                },
              }
            )
          }
          return new Response(
            JSON.stringify({ error: data.message || 'Failed to subscribe' }),
            {
              status: loopsResponse.status,
              headers: {
                'Content-Type': 'application/json',
                ...corsHeaders,
              },
            }
          )
        }

        return new Response(
          JSON.stringify({
            success: true,
            message: '🎃 Invite request received! We\'ll summon you soon...'
          }),
          {
            status: 200,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        )
      } catch (error) {
        console.error('Subscribe error:', error)
        return new Response(
          JSON.stringify({ error: 'Internal server error' }),
          {
            status: 500,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        )
      }
    }

    // Serve static assets for all other routes
    // This assumes the worker is deployed with Cloudflare Pages
    // or that static assets are bound via wrangler.toml
    return env.ASSETS.fetch(request)
  },
}
