function CodeDemo() {
  return (
    <>
      <div className="code-demo">
        <pre>
          <span className="output"># hello-world.yaml</span>
          {'\n\n'}
          <span style={{ color: '#ff7b72' }}>metadata</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n  '}
          <span style={{ color: '#79c0ff' }}>name</span>
          <span style={{ color: '#c9d1d9' }}>:</span> hello-world
          {'\n  '}
          <span style={{ color: '#79c0ff' }}>model</span>
          <span style={{ color: '#c9d1d9' }}>:</span> openai/gpt-oss-20b
          {'\n  '}
          <span style={{ color: '#79c0ff' }}>system_prompt</span>
          <span style={{ color: '#c9d1d9' }}>:</span> Make it spooky and short.
          {'\n\n'}
          <span style={{ color: '#ff7b72' }}>evals</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n  - '}
          <span style={{ color: '#79c0ff' }}>prompt</span>
          <span style={{ color: '#c9d1d9' }}>:</span> Say Hello
          {'\n    '}
          <span style={{ color: '#79c0ff' }}>checks</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>or</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n            '}
          <span style={{ color: '#79c0ff' }}>match</span>
          <span style={{ color: '#c9d1d9' }}>:</span>{' '}
          <span style={{ color: '#a5d6ff' }}>&quot;*wicked*&quot;</span>
          {'\n            '}
          <span style={{ color: '#79c0ff' }}>match</span>
          <span style={{ color: '#c9d1d9' }}>:</span>{' '}
          <span style={{ color: '#a5d6ff' }}>&quot;*dark*&quot;</span>
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>not_match</span>
          <span style={{ color: '#c9d1d9' }}>:</span>{' '}
          <span style={{ color: '#a5d6ff' }}>&quot;*smile*&quot;</span>
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>min_tokens</span>
          <span style={{ color: '#c9d1d9' }}>:</span> 10
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>max_tokens</span>
          <span style={{ color: '#c9d1d9' }}>:</span> 250
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>semantic</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n            '}
          <span style={{ color: '#79c0ff' }}>expected</span>
          <span style={{ color: '#c9d1d9' }}>:</span>{' '}
          <span style={{ color: '#a5d6ff' }}>&quot;Something wicked this way come.&quot;</span>
          {'\n            '}
          <span style={{ color: '#79c0ff' }}>threshold</span>
          <span style={{ color: '#c9d1d9' }}>:</span> 0.7
          {'\n        '}
          <span style={{ color: '#79c0ff' }}>llm_judge</span>
          <span style={{ color: '#c9d1d9' }}>:</span>
          {'\n            '}
          <span style={{ color: '#79c0ff' }}>criteria</span>
          <span style={{ color: '#c9d1d9' }}>:</span> This is a fitting respnose for a spooky halloween pop-up event
        </pre>
      </div>

      <div className="code-demo">
        <pre>
          <span className="prompt">$</span>{' '}
          <span className="command">vibe check hello-world.yaml</span>
          {'\n\n'}
          <span className="output">Running evals...</span>
          {'\n\n'}
          <span className="success">✓</span> Say Hello
          {'\n  '}
          <span className="success">✓</span> or                  {' '}
          <span style={{ color: '#7ee787' }}>passed</span>
          <span style={{ color: '#8b949e' }}>  match: wicked</span>
          {'\n  '}
          <span className="success">✓</span> not_match          {' '}
          <span style={{ color: '#7ee787' }}>passed</span>
          {'\n  '}
          <span className="success">✓</span> token_count        {' '}
          <span style={{ color: '#7ee787' }}>passed</span>
          <span style={{ color: '#8b949e' }}>  42 tokens</span>
          {'\n  '}
          <span className="success">✓</span> semantic           {' '}
          <span style={{ color: '#7ee787' }}>passed</span>
          <span style={{ color: '#8b949e' }}>  score: 0.85</span>
          {'\n  '}
          <span className="success">✓</span> llm_judge          {' '}
          <span style={{ color: '#7ee787' }}>passed</span>
          <span style={{ color: '#8b949e' }}>  perfectly spooky! 🎃</span>
          {'\n\n'}
          <span style={{ color: '#7ee787' }}>All checks passed!</span>{' '}
          <span style={{ color: '#8b949e' }}>(5/5)</span>
        </pre>
      </div>
    </>
  )
}

export default CodeDemo
