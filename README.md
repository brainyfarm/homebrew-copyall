# CopyAll

CopyAll is a customizable file copying script written in Bash. It allows you to generate a directory tree and output file contents based on specified options. With CopyAll, you can process files and directories according to your preferences, filter files by type, remove comments from code files, and more. The script also copies the generated output to your clipboard for easy access.

## Features

- **Include or exclude specific folders**: Specify which folders to include or exclude during processing.
- **Filter files by type**: Include only certain types of files based on their extensions.
- **Ignore test files and directories**: Optionally exclude files and directories related to testing.
- **Process only the `src` folder**: Limit processing to the `src` directory.
- **Remove comments from code files**: Clean up code files by removing comments.
- **Limit number of lines in file summaries**: Control how much of each file's content is included.
- **Set maximum file size for processing**: Skip files larger than a specified size.
- **Include hidden files and directories**: Optionally include files and directories that are hidden (start with a dot).
- **Control maximum depth for directory traversal**: Limit how deep the script traverses directories.
- **Verbose output and progress indicators**: Get detailed information about the script's execution.
- **Copies the output to clipboard**: Automatically copies the output to your clipboard.
- **Overwrites the output file instead of appending**: Ensures that each run starts fresh.
- **Automatically ignores files and directories specified in `.gitignore` and `.copyallignore`**: Respects your ignore files to avoid processing unwanted files.
- **Supports additional ignore patterns via `--exclude` and global git ignores**.
- **Custom output location with `--output-file`**.
- **Dry-run mode to preview actions without writing files**.

## Requirements

- **Operating System**: Tested on macOS 15.0 (Sonoma). Should work on other Unix-like systems with Bash installed, but clipboard functionality may vary.
- **Bash**: The script uses Bash shell scripting.
- **Clipboard Utility**: On macOS, it uses `pbcopy` to copy output to the clipboard. On Linux, it tries to use `xclip` or `xsel`.

## Installation

You can install CopyAll via Homebrew or from source.

### Install via Homebrew

1. **Add the Tap**:

    ```bash
    brew tap brainyfarm/homebrew-copyall
    ```

2. **Install CopyAll**:

    ```bash
    brew install copyall
    ```

### Install from Source

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/brainyfarm/homebrew-copyall.git
    ```

2. **Navigate to the Project Directory**:

    ```bash
    cd homebrew-copyall
    ```

3. **Install CopyAll**:

    Copy the `src` directory to a location in your PATH, and make sure `main.sh` is executable. Alternatively, you can create a wrapper script.

    For example:

    ```bash
    #!/bin/bash
    # Save this as /usr/local/bin/copyall and make it executable
    export PATH="/path/to/src:$PATH"
    exec "/path/to/src/main.sh" "$@"
    ```

    Replace `/path/to/src` with the actual path to your `src` directory.

## Usage

The basic syntax is:

```bash
copyall [options]
```

### Options

- `-f`, `--folders` : Comma-separated list of folders to include.
- `--file-types` : Comma-separated list of file types to include.
- `--exclude` : Comma-separated list of additional ignore patterns.
- `--output-file <path>` : Write output to a custom file path.
- `--dry-run` : Preview actions without writing output.
- `--ignore-tests` : Exclude test files and directories.
- `--src-only` : Only include the `src` folder.
- `--remove-comments` : Remove comments from code files.
- `--summary-lines <number>` : Number of lines for file summaries (0 for full content).
- `--max-file-size <bytes>` : Maximum file size in bytes for processing (default is 50000 bytes).
- `--include-hidden` : Include hidden files and directories.
- `--max-depth <number>` : Maximum depth for directory traversal (0 for unlimited).
- `--verbose` : Enable verbose output.
- `-h`, `--help` : Display help.

### Examples

- **Copy all files in `src` folder and copy output to clipboard**:

    ```bash
    copyall --src-only
    ```

- **Copy files with specific file types**:

    ```bash
    copyall --file-types sh,md
    ```

- **Include hidden files and limit depth**:

    ```bash
    copyall --include-hidden --max-depth 2
    ```

- **Remove comments and limit file summaries to first 50 lines**:

    ```bash
    copyall --remove-comments --summary-lines 50
    ```

- **Process only files under 10KB and include verbose output**:

    ```bash
    copyall --max-file-size 10000 --verbose
    ```

- **Preview which files will be processed without writing output**:

    ```bash
    copyall --dry-run
    ```

- **Write output to a custom location and ignore additional patterns**:

    ```bash
    copyall --output-file /tmp/out.txt --exclude "*.log,build"
    ```

- **Exclude test directories and process only specific folders**:

    ```bash
    copyall --ignore-tests -f src,lib
    ```

### Output

The script generates an output file `copyall/copyall.txt` containing:

- A tree structure of your files and directories.
- The contents of each file, optionally limited and filtered based on your options.

Additionally, the output is copied to your clipboard for easy pasting.

## How It Works

CopyAll traverses the specified directories, processing files according to the options you provide. It skips files and directories specified in your `.gitignore` and `.copyallignore` files, as well as any entries you specify with options like `--ignore-tests`.

### Ignored Files

The script automatically ignores:

- Files and directories listed in `.gitignore`.
- Files and directories listed in `.copyallignore`.
- The `copyall` directory itself (to prevent infinite loops).
- Test files and directories if `--ignore-tests` is specified.
- Non-specified folders if `--folders` option is used.
- Non-specified file types if `--file-types` option is used.
- Patterns specified via `--exclude`.
- Entries from your global git ignore file if configured.

## Advanced Usage

### Custom Ignore Patterns

You can create a `.copyallignore` file in your project root to specify additional files or directories to ignore.

**Example `.copyallignore`:**

```
node_modules
*.log
secret_config.yml
```

### Clipboard Support

On macOS, the script uses `pbcopy` to copy the output to the clipboard. On Linux, it tries to use `xclip` or `xsel`. If no clipboard utility is found, the script will notify you that the output was not copied to the clipboard.

## Project Structure

```
├── README.md
├── copyall.rb
└── src
    ├── config.sh
    ├── file_operations.sh
    ├── ignore_handler.sh
    ├── main.sh
    ├── tree_structure.sh
    └── utils.sh
```

- **`copyall.rb`**: Homebrew formula for installing CopyAll.
- **`src/`**: Directory containing all the source scripts.
  - **`main.sh`**: The main script that orchestrates the execution.
  - **`config.sh`**: Configuration variables and initial settings.
  - **`utils.sh`**: Utility functions for logging and argument parsing.
  - **`ignore_handler.sh`**: Functions for handling ignored files and directories.
  - **`file_operations.sh`**: Functions for processing files.
  - **`tree_structure.sh`**: Functions for generating the directory tree.

## Development

### Extending Functionality

Since CopyAll is written in modular Bash scripts, you can easily extend its functionality by modifying or adding scripts in the `src/` directory.

### Testing

To test the installation and functionality:

```bash
copyall --help
```

This should display the help message. If installed via Homebrew, the `copyall` command should be available globally.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

CopyAll is released under the [MIT License](LICENSE).

## Acknowledgments

Special thanks to all the contributors and users who have provided feedback and suggestions.

## Contact

For questions or suggestions, please open an issue on [GitHub](https://github.com/brainyfarm/homebrew-copyall/issues).

---

**Note**: This script has been tested on macOS 15.0 and works as expected. Clipboard functionality depends on the availability of clipboard utilities (`pbcopy`, `xclip`, or `xsel`) on your system.