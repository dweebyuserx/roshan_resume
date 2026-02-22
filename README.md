# Terminal Resume Portfolio

A single-file, zero-dependency terminal-style portfolio website with a Claude Code aesthetic.

## Quick Start

1. Open `index.html` in any browser - no server needed
2. Edit the `CONFIG` object in `index.html` to add your data
3. Deploy to GitHub Pages

## Customizing Your Data

Open `index.html` and find the `CONFIG` object near the top of the `<script>` section. Update these fields:

```javascript
const CONFIG = {
  // Basic Info
  name: { first: "Your", last: "Name" },
  handle: "yourhandle",           // Shows as ~/yourhandle.dev
  title: "Your Title",
  location: "City, Country",
  email: "you@example.com",
  yoe: 5,                         // Years of experience

  // Hero section
  tagline: "Your professional tagline...",
  heroTags: ["Skill1", "Skill2", "Skill3"],
  stack: ["Tech1", "Tech2", "Tech3"],

  // About paragraphs (use <strong> for highlights)
  aboutParagraphs: [...],

  // Skills with percentages
  skills: { languages: {...}, frontend: {...}, infrastructure: {...} },

  // Articles array
  articles: [...],

  // Projects array
  projects: [...],

  // Social connections
  connections: [...]
};
```

## Deploying to GitHub Pages

### Option 1: GitHub UI (Easiest)

1. Create a new repository on GitHub
2. Upload `index.html` to the repository
3. Go to **Settings** > **Pages**
4. Under "Source", select **main** branch and **/ (root)**
5. Click **Save**
6. Your site will be live at `https://yourusername.github.io/repository-name`

### Option 2: Git Command Line

```bash
# Initialize and push
git add index.html README.md
git commit -m "Initial portfolio setup"

# Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/your-repo.git

# Push to main branch
git push -u origin main
```

Then enable GitHub Pages in repository Settings > Pages.

### Option 3: GitHub Pages User Site

For a site at `yourusername.github.io`:

1. Create a repository named exactly `yourusername.github.io`
2. Push `index.html` to the main branch
3. The site automatically deploys to `https://yourusername.github.io`

## Features

- Single HTML file with inline CSS and JS
- No build tools, no npm, no frameworks
- Dark terminal aesthetic with CRT scanlines
- Custom cursor with smooth trailing ring
- Animated skill bars on scroll
- SVG connection lines with flowing dots
- Fully responsive design
- Scroll-triggered fade animations

## File Structure

```
/
  index.html     <- Homepage with all sections
  about.html     <- Detailed about page with experience & skills
  articles.html  <- Full articles listing with filtering
  projects.html  <- Projects showcase with featured project
  connect.html   <- Contact page with social links
  README.md      <- This file
```

## Browser Support

Works in all modern browsers (Chrome, Firefox, Safari, Edge). The custom cursor effect may not work on touch devices.

## License

MIT License
