---
name: mcp-integration
description: >-
  Add, configure, and manage Model Context Protocol (MCP) servers for
  extensible tooling. Define tool allowlists, authentication, environment
  variables, and tool schemas. Enables connecting Kilo to external APIs,
  databases, and custom services through the MCP standard.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/mcp-integration
    license_path: LICENSE
---

# MCP Integration

Configure and manage Model Context Protocol (MCP) servers to extend Kilo's
tooling capabilities. Connect to external APIs, databases, and custom
services through standardized MCP interfaces.

---

## Triggers

Use this skill when:
- "add an MCP server for this API"
- "connect to external service via MCP"
- "Model Context Protocol configuration"
- "create an MCP server wrapper"
- "configure MCP tools and authentication"
- "register a new MCP server in kilo.json"

Do NOT use for optimizing existing tools (use `tool-design-optimizer` for
that) or for one-off tool calls that don't need a persistent server.

---

## Process

### Phase 0: Requirements Analysis

Before implementing, clarify the integration requirements:

```markdown
## MCP Integration Spec

**External service:** <name, e.g., "GitHub API", "PostgreSQL">
**Purpose:** <what tools will this provide?>
**Auth required:** <none / API key / OAuth / bearer token>
**Transport:** <stdio / TCP / SSE>
**Existing MCP server available?** <yes/no — link if yes>

**Tools needed:**
| Tool Name | Description | Key Parameters |
|-----------|-------------|----------------|
| <tool-1> | <what it does> | <param list> |
| <tool-2> | <what it does> | <param list> |
```

**Decision: Use existing server or build custom?**
- **Existing server** (e.g., `@modelcontextprotocol/server-github`): Install and configure
- **Custom server**: Build a new MCP server wrapping the external API
- **Hybrid**: Use an existing server with custom tools added

---

### Phase 1: Install / Create MCP Server

#### Option A: Add an Existing MCP Server

Install the server package and configure in `kilo.json`:

```json
{
  "mcp": {
    "<server-name>": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "<package-name>"
      ],
      "env": {
        "<ENV_VAR>": "<value>"
      }
    }
  }
}
```

**Common configuration fields:**
| Field | Description | Required |
|-------|-------------|----------|
| `type` | Transport type: `local` (stdio), `remote` (SSE/TCP) | Yes |
| `command` | Command and args to start the server | For `local` type |
| `url` | URL of the remote MCP server | For `remote` type |
| `env` | Environment variables (API keys, config) | Optional |
| `disabled` | Set to `true` to temporarily disable | Optional |

**Authentication patterns:**
- **API key:** Pass via `env` as `API_KEY` or service-specific env var
- **Bearer token:** Pass via `env` as `TOKEN` or `AUTH_TOKEN`
- **OAuth:** Store refresh token in env; configure in server if supported

#### Option B: Create a Custom MCP Server

For services without an existing MCP server:

1. Determine the server type (stdio-based Node.js/Python script)
2. Implement the MCP protocol interface:
   - `list_tools` — return tool schemas
   - `call_tool` — execute tool and return results
3. Configure authentication and error handling
4. Add to `kilo.json` as a local server

**Minimal Node.js structure:**
```
mcp-servers/<service-name>/
  package.json
  index.js          # MCP server implementation
  README.md         # Usage documentation
```

**Minimal Python structure:**
```
mcp-servers/<service-name>/
  requirements.txt
  server.py         # MCP server implementation
  README.md         # Usage documentation
```

---

### Phase 2: Configure Tool Allowlists

For each MCP server, define which tools should be enabled:

```yaml
server: <server-name>
allowlist:
  - tool-1    # enabled — clear purpose
  - tool-2    # enabled — clear purpose
denylist:
  - tool-3    # disabled — destructive or irrelevant
```

**Guidelines for allowlisting:**
- Enable tools that match the integration's purpose
- Disable tools that are destructive, expensive, or irrelevant
- Document why each tool is enabled or disabled
- Revisit allowlist as needs evolve

---

### Phase 3: Test Tool Schemas & Invocation

Verify each allowed tool works correctly:

```markdown
## MCP Verification: <server-name>

### Tool: <tool-name>

**Schema verification:**
| Parameter | Type | Required | Default | OK? |
|-----------|------|----------|---------|-----|
| <param>   | <type> | Y/N    | <value> | ✅  |

**Test invocation:**
- **Input:** <test parameters>
- **Result:** ✅ / ❌
- **Response:** <truncated output>

**Edge cases tested:**
- [ ] Empty input: <result>
- [ ] Missing required params: <error behavior>
- [ ] Auth failure: <error behavior>
- [ ] Timeout: <error behavior>
```

**Minimum test coverage:**
- Happy path (typical usage)
- Missing required parameters (error handling)
- Authentication failure
- Network/service timeout
- Rate limiting (if applicable)

---

### Phase 4: Document & Wrap Up

```markdown
## MCP Integration Summary

**Server:** <name>
**Type:** <local / remote>
**Source:** <existing package / custom built in ./mcp-servers/>

**Tools registered:**
| Tool | Description | Status |
|------|-------------|--------|
| tool-1 | ... | ✅ Enabled |
| tool-2 | ... | ✅ Enabled |
| tool-3 | ... | ❌ Denied (reason) |

**Configuration in kilo.json:**
```json
{ "mcp": { "<server-name>": { ... } } }
```

**Environment variables required:**
- `<VAR>` — purpose (e.g., "GitHub personal access token")

**Security notes:**
- <any credentials stored, access restrictions, or risk mitigations>
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Hardcoding secrets in `kilo.json` | Use environment variables via `env` field |
| Enabling all tools without review | Create an explicit allowlist |
| Ignoring tool error messages | Test error paths and document expected errors |
| Using `sudo` or global installs | Use `npx -y` for Node.js servers |
| Multiple servers with conflicting tool names | Prefix tool names with the server identifier |
| Skipping auth testing | Always test authentication failure handling |

---

## Execution Checklist

```
[ ] Phase 0: Requirements documented (service, auth, tools needed)
[ ] Phase 1: Server installed or custom server created
[ ] Phase 2: Tool allowlist configured
[ ] Phase 2: Denylist documented for excluded tools
[ ] Phase 3: Each tool tested (happy path + error cases)
[ ] Phase 4: Configuration documented in kilo.json and README
[ ] Verify: No secrets hardcoded in kilo.json
[ ] Verify: Auth failure handled gracefully
[ ] Verify: Tool schemas complete and accurate
```

---

## Verification

After MCP integration:
1. Server starts and connects without errors
2. All allowed tools return correct results
3. All error paths (auth, network, invalid input) are handled gracefully
4. No secrets are hardcoded in configuration files
5. Tool allowlist is documented with rationale for each decision
6. `kilo.json` parses as valid JSON
