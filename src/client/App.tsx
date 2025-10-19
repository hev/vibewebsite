import Header from './components/Header'
import CTASection from './components/CTASection'
import CodeDemo from './components/CodeDemo'
import FAQ from './components/FAQ'
import Footer from './components/Footer'

function App() {
  return (
    <>
      <Header />
      <main>
        <div className="container">
          <CTASection />
          <CodeDemo />
        </div>
        <FAQ />
      </main>
      <Footer />
    </>
  )
}

export default App
