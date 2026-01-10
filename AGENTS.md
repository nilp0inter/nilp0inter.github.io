# Project context: Hugo Blog

## Project Overview

This directory contains a personal blog built using the [Hugo](https://gohugo.io/) static site generator. The site is online at `www.rusoblanco.com` and is deployed via GitHub Pages.

**Key Features:**

*   **Engine:** Hugo (v0.152.2 as per deployment workflow)
*   **Theme:** The theme, `rusoblanco-hugo-theme`, is included as a Git submodule located in the `themes/` directory. The theme's repository is at `https://github.com/nilp0inter/rusoblanco-hugo-theme.git`.
*   **Content:** Blog posts are written in Markdown and located in the `content/post/` directory.
*   **Deployment:** The site is automatically built and deployed to GitHub Pages on every push to the `main` branch, as configured in `.github/workflows/hugo.yml`.

## Building and Running

### Running Locally

To preview the site locally, run the Hugo server. This will build the site and serve it on a local port (usually `http://localhost:1313/`). The server will automatically rebuild the site when you make changes to content or theme files.

```bash
hugo server
```

To include draft posts in the local preview, use the `-D` flag:

```bash
hugo server -D
```

### Building for Production

The production build process is handled by the GitHub Actions workflow. The command used is:

```bash
hugo --gc --minify
```

This command generates the static site into the `public/` directory, which is then deployed to GitHub Pages.

## Development Conventions

### Content Creation

New blog posts can be created using the `hugo new` command. This will generate a new Markdown file in the `content/post/` directory based on the template in `archetypes/default.md`.

```bash
hugo new content post/your-new-post-title.md
```

The front matter of new posts defaults to:
```toml
+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
+++
```
Remember to update the `title` and set `draft = false` when you are ready to publish.

### Theme Modifications

*   The theme is a separate Git repository managed as a submodule.
*   **This theme is owned and actively developed as part of this project. Direct modifications to the theme are encouraged when necessary.**
*   **All changes to the theme must be committed within the `themes/rusoblanco-hugo-theme/` directory.**
*   Before making any changes, ensure both the main blog repository and the theme submodule repository are on the `main` branch.

### Commit and Synchronization Process

A strict process must be followed to keep the blog and theme synchronized.

1.  **Make changes:** Modify the theme or create new content.
2.  **Commit Theme (if changed):**
    *   Navigate to the theme directory: `cd themes/rusoblanco-hugo-theme`
    *   Stage and commit your changes. All commits must be GPG signed (`git commit -S`). Never skip signing, if an error occurs, abort the operation and inform the user immediately.
    *   `cd ../..` to return to the main project root.
3.  **Commit Blog:**
    *   Stage the updated theme submodule (`git add themes/rusoblanco-hugo-theme`) and any other changes (e.g., new content).
    *   Commit the changes for the main blog repository. This commit must also be GPG signed (`git commit -S`).
4.  **Confirmation:** Only commit changes after receiving positive validation from the user. Do not push changes unless explicitly asked.
