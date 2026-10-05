# Data Preparation Playbook

This stage summary supports `ai-pipeline` planning. At runtime, the
`ai-data-preparation` Workflow governs.

1. Identify data sources, ownership, modality, observation unit, and raw
   preservation policy.
2. Classify fields by semantic role, not only inferred storage type: identifiers,
   targets, timestamps, groups, measurements, categories, text, media, and
   metadata.
3. Measure missingness, duplicates, invalid values, ranges, units, encoding,
   cardinality, and cross-source alignment.
4. Distinguish absence, censoring, not-applicable values, and collection
   failures before choosing a treatment.
5. Apply the smallest justified conversions and cleaning rules. Record every
   lossy operation.
6. Package analysis-ready data with schema, provenance, and a reproducible run
   path.
7. Verify idempotence, row or entity accounting, schema expectations, and a
   material malformed-input path.

If split policy is unknown, do not fit learned imputers, scalers, vocabularies,
or encoders globally. Surface the dependency on problem modeling.
