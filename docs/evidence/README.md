# Evidências de execução

Resultados reais ficam em `evidence/local/`, ignorado pelo Git. Este diretório
versiona apenas o contrato de evidência e conclusões sanitizadas aprovadas.

## Modelo mínimo

```yaml
gate: F0
timestamp_utc: 1970-01-01T00:00:00Z
executor: papel-ou-identificador-nao-pessoal
reviewers: []
candidate_ref: commit-exato
environment: Development
tool_versions: {}
preconditions: []
expected: texto
observed: texto
exit_code: 0
artifacts: []
security_scan: not-run
residual_risks: []
decision: fail
```

Nunca inclua segredos, tokens, e-mail, chat, caminhos pessoais, payloads de
sessão ou conteúdo proprietário. Checksums permitidos devem identificar a
versão sem possibilitar reconstruir o material protegido.
