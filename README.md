# General description of the script
The run-node script allows you to execute Node.js, npm, npx, and other commands within a Docker container 
that uses the official Node.js image (node:22-alpine). 
This approach allows you to avoid installing Node.js 
and its dependencies locally on your system, instead running everything within the container.

# Explanation of the script code
## Definition of variables
```bash
APP_DIR="$(pwd)"\
PROJECT_NAME="$(basename "$APP_DIR‘)’\
VOLUME_NAME="node_modules_cache_${PROJECT_NAME//[^a-zA-Z0-9]/_}"\
NODE_IMAGE=‘node:22-alpine’
```

* APP_DIR: retrieves the current project directory (where the script you are running is located).
* PROJECT_NAME: takes the name of the project folder (e.g. my-project).
* VOLUME_NAME: creates a name for the Docker volume that will be used for the node_modules cache. It is based on the project name and replaces any non-alphanumeric characters with _ to ensure the Docker volume name is valid.
* NODE_IMAGE: specifies the Node.js Docker image to use, in this case node:22-alpine (a lightweight Node.js image based on Alpine Linux).

## Help function (show_help)
```bash
show_help() {
  echo ‘Usage:’
  echo ‘  node <file.js> [args...]         # Runs a Node.js script’
  echo ‘  node --repl                      # Starts interactive REPL’
  echo ‘  node --install                   # Runs “npm install”’
  echo ‘  node --run <script>              # Runs “npm run <script>”’
  echo ‘  node --npx <pkg> [args...]       # Runs “npx <pkg>”’
  echo ‘  node --clean                     # Clears the node_modules cache’
  echo ‘  node --help                      # Displays this message’
  exit 1
}
```

This function prints the help message showing how to use the script. It is invoked if no arguments are passed or if the user explicitly requests the --help option.

## Options management
The script handles several options using the case construct to perform specific actions based on the arguments provided. Here's how it works:
### REPL execution
```bash
if [ ‘$1’ == ‘--repl’ ]; then
  docker run -it --rm \
    -v ‘$APP_DIR’:/app \
    -v ‘$VOLUME_NAME’:/app/node_modules \
    -w /app \
    ‘$NODE_IMAGE’ \
    node
  exit 0
fi
```

If the user runs node --repl, the script starts an interactive Node.js REPL session in the Docker container.
It mounts the working directory (APP_DIR) in the container and the node_modules cache (Docker volume) to allow access to installed dependencies.

### Run npm install
```bash
if [ ‘$1’ == ‘--install’ ]; then
  docker run -it --rm \
    -v ‘$APP_DIR’:/app \
    -v ‘$VOLUME_NAME’:/app/node_modules \
    -w /app \
    ‘$NODE_IMAGE’ \
    npm install
  exit 0
fi
```

If the user runs node --install, the script executes npm install in the Docker container. 
This will install the dependencies defined in the project's package.json. 
The node_modules cache is mounted so that dependencies are not reinstalled each time, speeding up subsequent operations.

### Execute npm run <script>
```bash
if [ ‘$1’ == ‘--run’ ]; then
  if [ -z ‘$2’ ]; then
    echo ‘Error: specify a script to run (e.g. start, dev)’
    exit 1
  fi
  docker run -it --rm \
    -v ‘$APP_DIR’:/app \
    -v ‘$VOLUME_NAME’:/app/node_modules \
    -w /app \
    ‘$NODE_IMAGE’ \
    npm run ‘$2’
  exit 0
fi
```

If the user runs run-node --run <script>, the script executes the command npm run <script> in the Docker container. 
This allows you to run custom scripts defined in package.json, such as npm run dev, npm run build, etc.
