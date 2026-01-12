#!/bin/bash

# ==============================================================================
# Canonical TypeScript Setup Script for Node.js v24.x on macOS
# ==============================================================================
#
# This script automates the setup of a professional TypeScript development
# environment with Node.js v24.x.
#
# Prerequisites:
# - Node.js v24.x must be installed
# - npm must be available
# - gnu-sed must be installed (install via: brew install gnu-sed)
#
# What this script does:
# - Initializes a Node.js project with TypeScript support
# - Configures TypeScript compiler with Node.js 24 settings
# - Sets up ESLint with TypeScript support and code organization plugins
# - Configures Prettier for code formatting
# - Creates development and production scripts
# - Sets up VS Code workspace settings
# ==============================================================================

set -e  # Exit immediately if a command exits with a non-zero status

# ==============================================================================
# STEP 0: Check Directory Status
# ==============================================================================

echo "Checking directory status..."

# Count files in current directory excluding setup.sh and hidden files
file_count=$(find . -maxdepth 1 -type f ! -name "setup.sh" ! -name ".*" | wc -l | tr -d ' ')
dir_count=$(find . -maxdepth 1 -type d ! -name "." ! -name "..*" | wc -l | tr -d ' ')

if [ "$file_count" -gt 0 ] || [ "$dir_count" -gt 0 ]; then
  echo ""
  echo "WARNING: This directory is not empty!"
  echo "Found the following files and directories:"
  echo ""
  find . -maxdepth 1 ! -name "." ! -name "setup.sh" ! -path "*/\.*"
  echo ""
  echo "This script is intended to be run in an empty directory."
  echo "Running it here may overwrite existing files or cause conflicts."
  echo ""
  read -p "Do you want to continue anyway? (yes/no): " response
  
  if [[ ! "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Setup cancelled."
    exit 0
  fi
  
  echo "Continuing setup in non-empty directory..."
fi

echo "Directory check complete."

# ==============================================================================
# STEP 1: Validate Environment
# ==============================================================================

echo ""
echo "Validating Node.js version..."

if ! node -v | grep -q '^v24\.'; then
  echo "ERROR: This script requires Node.js version 24.x"
  echo "Current version: $(node -v)"
  echo "Please install Node.js 24.x before running this script."
  exit 1
fi

echo "Node.js version $(node -v) detected."

# ==============================================================================
# STEP 2: Initialize Project
# ==============================================================================

echo ""
echo "Initializing Node.js project..."

# Create .nvmrc file to ensure correct Node.js version
# This allows tools like nvm to automatically switch to the correct version
node -v > .nvmrc

# Initialize package.json with default settings
npm init -y

echo "Project initialized successfully."

# ==============================================================================
# STEP 3: Configure Module System
# ==============================================================================

echo ""
echo "Configuring ES modules..."

# Add "type": "module" to package.json to enable ES modules
# This allows using import/export syntax instead of require/module.exports
gsed -i 's#"main": "index.js",#"type": "module",\n  "main": "index.js",#' package.json

echo "ES module configuration complete."

# ==============================================================================
# STEP 4: Install TypeScript and Core Dependencies
# ==============================================================================

echo ""
echo "Installing TypeScript and core dependencies..."

# Install TypeScript compiler and runtime utilities
# - typescript: The TypeScript compiler
# - @types/node: Type definitions for Node.js APIs
# - @tsconfig/node24: Recommended TypeScript configuration for Node.js 24
# - tsx: Fast TypeScript execution and watch mode for development
npm install --save-dev typescript @types/node @tsconfig/node24 tsx

echo "TypeScript dependencies installed."

# NOTE: Uncomment the following line to install Express.js framework
# npm install express @types/express

# ==============================================================================
# STEP 5: Configure TypeScript
# ==============================================================================

echo ""
echo "Configuring TypeScript compiler..."

# Generate initial tsconfig.json with source and output directories
npx tsc --init --rootDir src --outDir dist

# Extend the Node.js 24 recommended configuration
# This provides optimal settings for Node.js 24 compatibility
gsed -i '2i \  "extends": "@tsconfig/node24/tsconfig.json",' tsconfig.json

# Comment out generic environment settings
# These are replaced by Node.js-specific settings below
gsed -i 's#^[[:space:]]*"module": "nodenext",#    // "module": "nodenext",#' tsconfig.json
gsed -i 's#^[[:space:]]*"target": "esnext",#    // "target": "esnext",#' tsconfig.json
gsed -i 's#^[[:space:]]*"types": \[\],#    // "types": [],#' tsconfig.json

# Uncomment Node.js-specific environment settings
# This enables proper lib and types configuration for Node.js development
gsed -i 's#// "lib": \["esnext"\],#"lib": ["esnext"],#' tsconfig.json
gsed -i 's#// "types": \["node"\],#"types": ["node"],#' tsconfig.json

echo "TypeScript configuration complete."

# ==============================================================================
# STEP 6: Configure Package Scripts
# ==============================================================================

echo ""
echo "Configuring package.json scripts..."

# Update the main entry point to the compiled output
gsed -i 's#"main": "index.js"#"main": "dist/index.js"#' package.json

# Add development and production scripts
# - dev: Run with hot reload during development
# - build: Compile TypeScript to JavaScript
# - start: Run the compiled JavaScript
# - type-check: Verify types without emitting files
gsed -i 's#"scripts": {#"scripts": {\n    "dev": "tsx --watch src/index.ts",\n    "build": "tsc",\n    "start": "node dist/index.js",\n    "type-check": "tsc --noEmit",#' package.json

echo "Package scripts configured."

# ==============================================================================
# STEP 7: Setup Prettier for Code Formatting
# ==============================================================================

echo ""
echo "Setting up Prettier..."

# Install Prettier as a development dependency
npm install --save-dev prettier

# Create Prettier configuration file with default settings
echo '{}' > .prettierrc.json

echo "Prettier configured."

# ==============================================================================
# STEP 8: Setup ESLint for Code Quality
# ==============================================================================

echo ""
echo "Setting up ESLint..."

# Install ESLint core packages and TypeScript support
# - eslint: Core linting engine
# - @eslint/js: JavaScript recommended rules
# - globals: Standard JavaScript global variables
# - typescript-eslint: TypeScript-specific linting rules
npm install --save-dev eslint @eslint/js globals typescript-eslint

# Create ESLint configuration file
cat > eslint.config.mjs << 'EOF'
import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import { defineConfig } from "eslint/config";

export default defineConfig([
  { files: ["**/*.{js,mjs,cjs,ts,mts,cts}"], plugins: { js }, extends: ["js/recommended"], languageOptions: { globals: globals.node } },
  tseslint.configs.recommended,
]);
EOF

echo "ESLint base configuration complete."

# ==============================================================================
# STEP 9: Add ESLint Perfectionist Plugin
# ==============================================================================

echo ""
echo "Adding ESLint Perfectionist plugin..."

# Install perfectionist plugin for automatic code organization
# This plugin enforces consistent ordering of imports, exports, and object keys
npm install --save-dev eslint-plugin-perfectionist

# Add perfectionist plugin import to ESLint configuration
gsed -i '5i import perfectionist from "eslint-plugin-perfectionist";' eslint.config.mjs

# Add perfectionist recommended rules to ESLint configuration
gsed -i '10i \  perfectionist.configs["recommended-natural"],' eslint.config.mjs

# Format ESLint configuration file using ESLint itself
npx eslint --fix eslint.config.mjs

echo "ESLint Perfectionist plugin configured."

# ==============================================================================
# STEP 10: Setup VS Code Workspace Settings
# ==============================================================================

echo ""
echo "Creating VS Code workspace settings..."

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Create settings.json with auto-fix on save enabled
# This automatically runs ESLint and Prettier fixes when saving files
cat > .vscode/settings.json << 'EOF'
{
  "editor.tabSize": 2,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit"
  }
}
EOF

echo "VS Code settings configured."

# ==============================================================================
# STEP 11: Create .gitignore File
# ==============================================================================

echo ""
echo "Creating .gitignore file..."

# Create .gitignore to exclude node_modules and dist directories
# Reference: https://github.com/github/gitignore/blob/main/Node.gitignore
cat > .gitignore << 'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules/
jspm_packages/

# Snowpack dependency directory (https://snowpack.dev/)
web_modules/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variable files
.env
.env.*
!.env.example

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next
out

# Nuxt.js build / generate output
.nuxt
dist
.output

# Gatsby files
.cache/
# Comment in the public line in if your project uses Gatsby and not Next.js
# https://nextjs.org/blog/next-9-1#public-directory-support
# public

# vuepress build output
.vuepress/dist

# vuepress v2.x temp and cache directory
.temp
.cache

# Sveltekit cache directory
.svelte-kit/

# vitepress build output
**/.vitepress/dist

# vitepress cache directory
**/.vitepress/cache

# Docusaurus cache and generated files
.docusaurus

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# Firebase cache directory
.firebase/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# yarn v3
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions

# Vite files
vite.config.js.timestamp-*
vite.config.ts.timestamp-*
.vite/
EOF

echo ".gitignore file created."

# ==============================================================================
# STEP 12: Create Project Structure
# ==============================================================================

echo ""
echo "Creating project structure..."

# Create source directory
mkdir -p src

# Create initial TypeScript file with a simple example
echo 'console.log("Hello, TypeScript!");' > src/index.ts

echo "Project structure created."

# ==============================================================================
# Setup Complete
# ==============================================================================

echo ""
echo "===================================================================="
echo "Setup complete! Your TypeScript project is ready for development."
echo "===================================================================="
echo ""
echo "Available commands:"
echo "  npm run dev        - Start development mode with hot reload"
echo "  npm run build      - Compile TypeScript to JavaScript"
echo "  npm run start      - Run the compiled application"
echo "  npm run type-check - Verify TypeScript types"
echo ""
echo "Next steps:"
echo "  1. Update package.json with your project details:"
echo "     - name: Your project name"
echo "     - description: Project description"
echo "     - author: Your name or organization"
echo "     - license: License type (e.g., MIT, ISC)"
echo "  2. Edit src/index.ts to start coding"
echo "  3. Run 'npm run dev' to start development mode"
echo "  4. VS Code will auto-fix code on save"
echo "===================================================================="