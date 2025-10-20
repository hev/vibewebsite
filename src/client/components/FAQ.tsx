function FAQ() {
  return (
    <section className="faq" id="faq">
      <div className="container">
        <h2>FAQ</h2>
        <dl className="faq-list">
          <div className="faq-item">
            <dt>What is an eval?</dt>
            <dd>
              An eval is a small, repeatable test that helps you measure an LLM’s
              behavior on tasks you care about. It’s how you track whether changes
              improve or regress quality over time.
            </dd>
          </div>
          <div className="faq-item">
            <dt>What is a pop-up?</dt>
            <dd>
              We’re offering vibe check as a limited-run pop-up service at no cost
              as a trial for the concept.
            </dd>
          </div>
          <div className="faq-item">
            <dt>How much does it cost?</dt>
            <dd>
              It's free! Actually better than free, we're sponsoring invitees with credits to
              spend.
            </dd>
          </div>
          <div className="faq-item">
            <dt>How are run prices calculated?</dt>
            <dd>
              Run prices are determined by aggregating pricing data from our inference providers and applying a margin. We plan to actively conduct pricing experiments during the pop up so you may notice pricing and credit amounts change unexpectedly.
            </dd>
          </div>
          <div className="faq-item">
            <dt>How do I get invited?</dt>
            <dd>
              Using an email that helps us understand why you might be interested
              running evals increases your chances of getting selected.
            </dd>
          </div>
          <div className="faq-item">
            <dt>What’s after the pop-up?</dt>
            <dd>
              Depending on feedback, we plan to roll out a private preview some
              time next month. You’ll have a chance to join the private preview if
              you are invited to the pop-up.
            </dd>
          </div>
          <div className="faq-item">
            <dt>What’s your data retention policy?</dt>
            <dd>
              Your data will be deleted forever on November 1st (but the CLI saves
              local copies of your runs).
            </dd>
          </div>
          <div className="faq-item">
            <dt>Is my data safe?</dt>
            <dd>
              Your data will be in a multi-tenant database on a new untested cloud
              service. We don’t recommend putting sensitive data in your evals
              during the pop-up. We promise to delete your data and not share it,
              but all you have is our word on this.
            </dd>
          </div>
          <div className="faq-item">
            <dt>How do I get started?</dt>
            <dd>
              Check out the code and instructions in our GitHub repo:
              {' '}
              <a href="https://github.com/hev/vibecheck" target="_blank" rel="noreferrer">
                github.com/hev/vibecheck
              </a>
              .
            </dd>
          </div>
          <div className="faq-item">
            <dt>Who do I contact for help?</dt>
            <dd>
              Reply to the invite email or open an issue in the GitHub repo above.
            </dd>
          </div>
        </dl>
      </div>
    </section>
  )
}

export default FAQ


