---
task_id: 2026-06-05_enhancement-plan
status: pending
date: 2026-06-05
agent: request-translator
intent: Plan for test-expert agent enhancements
---

# Enhancement Plan for Test Expert Agents

## Objectives
Enhance test-expert and test-expert-free agents to:
1. Generate adversarial/malicious input tests
2. Implement fallback/retry mechanisms
3. Prevent system breaches through security-focused testing
4. Challenge improper inputs systematically

## Phase 1: Enhanced Test Categories (Week 1)

### New Test Categories to Add
| Category | Description | Priority |
|----------|-------------|----------|
| `malicious-inputs` | SQL injection, XSS, command injection payloads | Critical |
| `boundary-overflow` | Buffer overflows, integer overflows, max length exceeded | Critical |
| `type-confusion` | Wrong types passed to functions, null/undefined handling | High |
| `state-corruption` | Invalid state transitions, race conditions | High |
| `resource-exhaustion` | Large payloads, infinite loops, memory bombs | Medium |

### Updated Workflow (test-gen.md)
Add STEP 2.5: ADVERSARIAL ANALYSIS
- Map security-relevant inputs for each function
- Identify external data sources (user input, APIs, files)
- Generate attack vectors per OWASP Top 10

## Phase 2: Fallback Mechanisms (Week 1)

### Test Generation Retry Logic
```
for attempt in 1..3:
    try:
        generate_tests(category)
        if verify_tests(): break
    except GenerationError:
        adjust_parameters()
        continue
else:
    log_failure_and_suggest_manual()
```

### Fallback Strategies
| Failure Type | Fallback Action |
|--------------|-----------------|
| Syntax error | Retry with simplified test structure |
| Import failure | Mock missing dependencies |
| Coverage < threshold | Add integration test placeholders |
| Flaky test | Mark as @flaky, retry 3x in CI |

## Phase 3: Breach Prevention Tests (Week 2)

### Security Test Patterns
- **Input Sanitization**: Verify all inputs are sanitized before use
- **Authorization Bypass**: Test privilege escalation paths
- **Data Leakage**: Check error messages don't expose internals
- **DoS Resilience**: Test rate limiting, large payloads
- **Crypto Validation**: Verify proper encryption/decryption usage

### Test Generation Rules
1. Every public API gets `malicious-inputs` tests
2. Every data processor gets `boundary-overflow` tests
3. Every auth function gets `authorization-bypass` tests
4. All tests must pass `no-secrets-in-code` check

## Phase 4: Implementation Updates

### Files to Modify
1. `agent/test-expert.md` - Add adversarial workflow
2. `agent/test-expert-free.md` - Same enhancements
3. `command/test-gen.md` - Enhanced workflow steps

### New Agent Sections
```
## ADVERSARIAL TEST GENERATION

### STEP 2.5: ADVERSARIAL ANALYSIS
- Identify attack surface per function
- Map OWASP categories to input vectors
- Generate malicious payload sets

### STEP 3.5: FALLBACK GENERATION
- On test failure, apply fallback strategy
- Generate minimal passing test + TODO
- Log for manual review

### STEP 4.5: SECURITY VERIFICATION
- Run bandit/semgrep on generated tests
- Verify no hardcoded secrets
- Check for proper input validation
```

## Success Metrics
| Metric | Target |
|--------|--------|
| Malicious input coverage | 100% of public APIs |
| Test generation success rate | >95% with fallback |
| Security test false positives | <5% |
| Breach prevention test coverage | All auth + data handlers |

## Timeline
- **Week 1**: Phase 1 & 2 (categories + fallbacks)
- **Week 2**: Phase 3 & 4 (security tests + implementation)

## Risk Mitigation
- Maintain backward compatibility with existing tests
- Feature flag new categories (`ENABLE_ADVERSARIAL_TESTS=true`)
- Gradual rollout with A/B comparison

---
*Plan created: 2026-06-05*
*Next review: 2026-06-12*