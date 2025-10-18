import Header from './components/Header'
import CTASection from './components/CTASection'
import CodeDemo from './components/CodeDemo'
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
      </main>
      <Footer />
    </>
  )
}

export default App
