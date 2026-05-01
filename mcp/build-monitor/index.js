const fs = require('fs');
const path = require('path');

/**
 * A simple MCP-like bridge for OpenCode.
 * It reads a 'build.log' file from the /app directory (mounted from host).
 */

const LOG_FILE = '/app/build.log';

async function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    if (command === 'check') {
        if (!fs.existsSync(LOG_FILE)) {
            console.log("No build.log found. Please run your build on the host and redirect output to build.log (e.g., msbuild /v:m > build.log)");
            return;
        }

        const content = fs.readFileSync(LOG_FILE, 'utf8');
        const lines = content.split('\n');
        
        // Find lines containing "error" or "failed" (case insensitive)
        const errors = lines.filter(line => /error|failed/i.test(line));

        if (errors.length > 0) {
            console.log("--- Found Errors in Build Log ---");
            console.log(errors.join('\n'));
        } else {
            console.log("--- Build Log looks clean (no errors found) ---");
            console.log("Last 5 lines:");
            console.log(lines.slice(-5).join('\n'));
        }
    } else {
        console.log("Usage: node build-monitor.js check");
    }
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
