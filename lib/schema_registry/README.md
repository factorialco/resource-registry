# Schema registry

A json-schema based registry

## Features

- Versioning
  - Unneeded version blocking through CI/CD
  - Required version blocking through CI/CD
  - Lifecycle / States: Dead, Stable, Next (alpha/beta)
  - `schema_registry version:bump employee`
  - Track version usage to clean up unused deprecated versions
- Typing (?) -> Sorbet
- Validation

## What is an schema?

- Metadata (generated files, similar to RBI generation)

  - Last stable json-schema
  - Last unstable tag

- Schema itself (json-schema)

## Adding a new schema

Just drop a json-schema formatted in YAML into your-component/app/schemas
folder and the SchemaRegistry system will load it automatically into the
registry for you.

## Generating RBIs from schemas

```bash
bin/rails schema_registry:generate_rbis
```

## Generate a json-schema representation of a T::Struct

This is specially useful when you need to define the initial version of a
json-schema for an entity or DTO since both are usually defined with
`T::Struct`.

```bash
bin/rails "schema_registry:generate_schema_from_struct[Ats::Entities::JobPosting]"
```

## What abstractions can use schemas?

- DTOs (Repositories parameters shape)
- Entities
- Events

## To research

- [JSON-ld](https://json-ld.org/)
