# Contributing to Antigravity IDE Updater

Thank you for your interest in improving the **Antigravity IDE Updater**!

## How to Contribute

1. **Fork the Repository**:
   Click the "Fork" button at the top right of this page.

2. **Clone your fork**:
   ```bash
   git clone https://github.com/<your-username>/antigravity-updater.git
   cd antigravity-updater
   ```

3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```

4. **Make Your Changes**:
   * Adhere to zero external heavy dependency rules (use native bash, PowerShell, and AppleScript).
   * Ensure scripts are clean and pass syntax validation:
     * Bash: `shellcheck linux/* macos/* install.sh`
     * PowerShell: `Invoke-ScriptAnalyzer -Path windows/`

5. **Commit & Push**:
   ```bash
   git commit -m "feat: describe your change"
   git push origin feature/my-new-feature
   ```

6. **Submit a Pull Request**:
   Open a PR against the `main` branch with a clear description of what was changed and why.

## Code of Conduct

Please maintain a welcoming and inclusive community. Be respectful and collaborative in issues and pull requests.
