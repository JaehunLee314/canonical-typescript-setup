# Canonical TypeScript Setup

An automated setup script for creating professional TypeScript development environments with Node.js v22.x on macOS.

## Prerequisites

- Node.js v22.x
- npm
- gnu-sed (install via: `brew install gnu-sed`)

## Usage

Run the setup script in an empty directory:

```bash
bash setup.sh
```

The script will automatically configure:

- TypeScript with Node.js 22 optimized settings
- ESLint with TypeScript support and code organization
- Prettier for code formatting
- VS Code workspace settings with auto-fix on save
- Development and production build scripts

## Available Commands

After setup, use these npm scripts:

- `npm run dev` - Start development mode with hot reload
- `npm run build` - Compile TypeScript to JavaScript
- `npm run start` - Run the compiled application
- `npm run type-check` - Verify TypeScript types

## Project Structure

```
.
├── src/
│   └── index.ts          # Main application entry point
├── dist/                 # Compiled JavaScript output
├── .vscode/
│   └── settings.json     # VS Code workspace settings
├── tsconfig.json         # TypeScript configuration
├── eslint.config.mjs     # ESLint configuration
├── .prettierrc.json      # Prettier configuration
├── .nvmrc                # Node.js version specification
└── package.json          # Project dependencies and scripts
```

## License

MIT License - see LICENSE file for details.

## Author

Jaehun Lee
