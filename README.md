# Restate Development Batch Scripts

These batch files help you manage your Restate development environment on Windows.

## Files Overview

### 1. **start.bat**

Starts the Restate Docker container and your project dev server sequentially.

- Cleans up any existing containers
- Starts Docker in detached mode
- Waits for initialization
- Runs `npm run dev`

### 2. **register.bat**

Registers your service with Restate.

- Checks if Docker is running
- Registers deployment at `http://host.docker.internal:9080`
- Provides error handling

### 3. **cleanup.bat**

Cleans up Docker containers and resources.

- Stops running containers
- Removes containers
- Shows current running containers

### 4. **run-all.bat** (Recommended)

Runs all steps automatically in sequence.

- Starts Docker
- Starts dev server in separate window
- Registers service
- Provides status updates and links

## Usage

### Quick Start (Recommended)

```cmd
run-all.bat
```

This runs all steps automatically.

### Manual Step-by-Step

```cmd
# Step 1: Start infrastructure
start.bat

# Step 2: In a separate terminal, register service
register.bat

# Step 3: When done, cleanup
cleanup.bat
```

## Important Notes

1. **Docker Requirements**

   - Docker Desktop must be running
   - Required ports: 8080, 9070, 9071, 9080

2. **Project Requirements**

   - `npm run dev` must be configured in package.json
   - Service must expose endpoint on port 9080

3. **Access Points**
   - Restate Dashboard: http://localhost:9070
   - Restate API: http://localhost:8080
   - Your Dev Server: (depends on your configuration)

## Troubleshooting

### "Docker is not running"

- Start Docker Desktop
- Wait for it to fully initialize

### "Port already in use"

- Run `cleanup.bat` first
- Check for other processes using ports 8080, 9070, 9071

### "Service registration failed"

- Ensure your dev server is running
- Verify it's accessible at http://host.docker.internal:9080
- Check dev server logs for errors

### Container conflicts

- Run `cleanup.bat` to remove old containers
- Use `docker ps -a` to see all containers

## Customization

### Change NPM Script

Edit `start.bat` or `run-all.bat` and replace:

```batch
npm run dev
```

with your desired command.

### Change Service Port

Edit `register.bat` and `run-all.bat`, replace:

```batch
http://host.docker.internal:9080
```

with your service port.

### Adjust Wait Times

In `run-all.bat`, modify the timeout values:

```batch
timeout /t 8 /nobreak >nul  REM Adjust the 8 to your needs
```

## Development Workflow

1. Start development: `run-all.bat`
2. Make code changes (dev server auto-reloads)
3. Re-register if needed: `register.bat`
4. Clean up when done: `cleanup.bat`
