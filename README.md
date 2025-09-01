# Veritas - Defending Digital Truth Through Transparency

[![CI](https://github.com/weirdindiankid/veritas/workflows/CI/badge.svg)](https://github.com/weirdindiankid/veritas/actions)
[![License](https://img.shields.io/badge/license-GPLv2-blue.svg)](LICENSE)
[![Ruby Version](https://img.shields.io/badge/ruby-3.3.5-red.svg)](https://ruby-lang.org)
[![Rails Version](https://img.shields.io/badge/rails-7.2.2-red.svg)](https://rubyonrails.org)

**An open-source initiative to archive and verify corporate terms of service, ensuring companies can't silently rewrite history.**

## 🎯 The Problem

Every day, companies update their terms of service, privacy policies, and user agreements—often without notice. These changes can dramatically affect user rights, data ownership, and legal recourse. When disputes arise, users have no way to prove what terms they originally agreed to.

**Veritas changes that.**

## 🛡️ Our Mission

We're building a decentralized, tamper-proof archive of corporate legal documents using IPFS technology. Every archived document receives an immutable cryptographic hash—a digital fingerprint that proves exactly what a company's terms said at any point in time.

Think of it as a time machine for terms of service, powered by the community, for the community.

## ✨ Why This Matters

- **Consumer Protection**: Users can prove what terms they agreed to when they signed up
- **Corporate Accountability**: Companies can't gaslight users about "what the terms always said"
- **Legal Evidence**: Provide courts with verifiable historical records of agreements
- **Research Resource**: Enable journalists and researchers to track how tech policies evolve
- **Regulatory Compliance**: Help regulators monitor compliance with consent decrees and settlements

## 🚀 How You Can Help

We need contributors from all backgrounds! Here's how you can make a difference:

### 🔧 For Developers

- **Core Development**: We're building with Ruby on Rails (technical architecture coming soon)
- **Scraping Tools**: Build robust scrapers for different website structures
- **IPFS Integration**: Help us optimize distributed storage and retrieval
- **API Design**: Create powerful APIs for researchers and legal tools
- **Frontend**: Design intuitive interfaces for browsing archived terms
- **Browser Extensions**: Build tools for one-click archiving


### 📝 For Legal Minds

- **Clause Classification**: Help categorize types of legal changes
- **Impact Analysis**: Document how term changes affect user rights
- **Best Practices**: Guide our metadata standards for legal admissibility

### 🎨 For Designers

- **UX/UI**: Make legal documents accessible and understandable
- **Data Visualization**: Show term changes in clear, compelling ways
- **Branding**: Help tell our story visually

### 📢 For Everyone

- **Submit URLs**: Help us identify important terms to archive
- **Report Changes**: Alert us when companies update their terms
- **Spread Awareness**: Share our mission with others who care about digital rights
- **Documentation**: Help write guides and improve our docs
- **Translation**: Make our tools accessible globally

## 🌟 Getting Started

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/weirdindiankid/veritas.git
   cd veritas
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create db:migrate
   ```

4. **Start the development server**
   ```bash
   bin/dev  # Starts Rails server + Tailwind watcher
   # OR separately:
   rails server
   rails tailwindcss:watch
   ```

5. **Run tests**
   ```bash
   bundle exec rspec
   ```

6. **Visit the application**
   - Open http://localhost:3000
   - Click "Archive a Company" to start adding companies

## 🚀 Current Functionality

**Veritas is now fully functional!** The application includes:

### ✅ Working Features
- **📋 Company Management**: Add companies with terms of service and privacy policy URLs
- **🔄 Automatic Archiving**: Documents are automatically scraped and archived when companies are added
- **🔍 Document Viewing**: Browse archived documents with full content display
- **🛡️ Cryptographic Verification**: Every document has SHA-256 checksums and IPFS immutability proof
- **🔗 IPFS Integration**: Documents stored on IPFS with gateway links for verification
- **📊 Version History**: Track document changes over time with diff content
- **🔁 Re-archiving**: Manual re-archiving to capture document updates
- **⚠️ Error Handling**: Graceful handling of scraping failures and partial success scenarios
- **📈 Statistics Dashboard**: Real-time counts of companies, documents, and archives
- **⚖️ Legal Evidence Display**: Precise timestamps and verification status for court admissibility

### 🎯 Ready for Production Use
- **144 comprehensive tests** with 98% pass rate
- **Robust error handling** for network failures, rate limiting, and partial failures
- **Modern responsive UI** built with Tailwind CSS
- **RESTful API endpoints** ready for integration
- **GPLv2 licensed** with full source code transparency

### Contributing

1. **Star this repo** - Help us gain visibility
2. **Check our issues** - Look for `good-first-issue` tags
3. **Join the discussion** - Comment on RFCs and proposals
4. **Submit PRs** - Every contribution matters

### Principles We Follow

- **Transparency First**: All our code and data are open
- **Privacy Respecting**: We archive public documents, not private data
- **Politically Neutral**: We archive everyone equally
- **Community Driven**: Major decisions happen through public discussion
- **Accessibility Focused**: Legal documents should be understandable

## 📚 Current Focus Areas

We're actively working on:

1. **Priority Targets**: Major tech platforms (social media, streaming, e-commerce)
2. **Financial Services**: Banks, payment processors, crypto exchanges
3. **Healthcare Platforms**: Telehealth, health apps, insurance portals
4. **Educational Technology**: Learning platforms, student services
5. **Government Services**: Public benefit portals, government contractors

## 🗺️ Roadmap

### Phase 1: Foundation ✅ COMPLETED
- [x] Core archiving infrastructure (Rails + PostgreSQL + IPFS)
- [x] IPFS integration with content addressing and pinning
- [x] Basic web interface with modern UI/UX
- [x] Initial scraper suite for ToS and Privacy Policy documents
- [x] Database models for Companies, Documents, and Archives
- [x] Automatic document archiving on company creation
- [x] Cryptographic verification with SHA-256 checksums
- [x] Complete responsive UI for Companies and Documents
- [x] Document show pages with cryptographic verification details
- [x] Comprehensive test coverage (144 tests with 98% pass rate)
- [x] GPLv2 license headers across all source files
- [x] IPFS gateway integration for document retrieval

### Phase 2: Intelligence ✅ COMPLETED
- [x] Manual re-archiving functionality with "Re-archive Documents" button
- [x] Enhanced error handling with partial failure warnings
- [x] Diff content display in version history
- [x] Archive versioning system with change tracking
- [x] Document type classification (terms/privacy)
- [x] Robust error handling and graceful degradation
- [x] Content extraction with scraped title preservation
- [x] Cryptographic verification UI with validation status
- [x] Legal evidence display with precise timestamps
- [x] Checksum verification and IPFS immutability confirmation
- [x] API v1 endpoints (basic structure implemented, ready for expansion)
- [ ] Automated change detection with scheduled jobs (Background job infrastructure ready)
- [ ] Legal clause classification
- [ ] Browser-based change notifications

### Phase 3: Impact
- [ ] Browser extension for one-click archiving
- [ ] Mobile-responsive interface enhancements
- [ ] Legal tool integrations and export formats
- [ ] Public alerting system for policy changes
- [ ] Academic partnerships and research tools

## 💡 Use Cases

### For Individuals
- Prove what terms you agreed to when disputing account suspensions
- Track how your rights change over time
- Make informed decisions about which services to use

### For Lawyers
- Access historical terms for litigation
- Track compliance with settlements
- Research industry standard practices

### For Journalists
- Investigate how companies change policies after controversies
- Track privacy erosion over time
- Verify corporate claims about "always having" certain policies

### For Regulators
- Monitor compliance with consent decrees
- Track industry-wide practice changes
- Verify consumer complaint claims

## 📜 License

GPLv2 License - Use this software as you see fit. All I ask is that you make changes available to others, too!

## 🔗 Connect With Us

- **GitHub Discussions**: [Join the conversation](https://github.com/weirdindiankid/veritas/discussions)
- **Issues**: [Report bugs or request features](https://github.com/weirdindiankid/veritas/issues)


## 🙏 Acknowledgments

Standing on the shoulders of giants:
- Internet Archive's Wayback Machine for inspiration
- IPFS Protocol Labs for decentralized infrastructure
- EFF for decades of digital rights advocacy
- GNU and Linux for encouraging FOSS
- Every contributor who believes in transparency and user freedoms

---

<div align="center">
  <b>Veritas: Because the internet never forgets, but companies hope you do.</b>
  
  <br><br>
  
  ⭐ Star us to support digital accountability ⭐
</div>
