# Turnover - Step 4: Design Data Model

## Goal

Produce a clear data model design that is specific enough to guide screen, service, and storage implementation.

## Tasks

- Choose a local-first persistence approach
- Define the core entities needed for run tracking and analytics
- Separate persisted run history from live tracking state
- Define how an in-progress run moves through start, pause, resume, and finish states
- Identify which values are raw inputs versus derived metrics
- Identify settings and profile inputs that affect analytics
- Resolve the V1 model decisions that affect behavior and scope

## Deliverables

- A detailed design doc at [docs/design/data-model.md](/Users/iamce/dev/electric/turnover/docs/design/data-model.md)
- Defined entities and relationships for V1 run tracking and analytics
- A documented distinction between persisted history, live session state, and user configuration
- Resolved V1 decisions for heart rate support, event retention, PR storage, and data post-processing

## Decisions

- Keep the Step 4 model storage-agnostic and finalize the concrete persistence layer during implementation
- Resolve V1 behavior questions now in the design doc, and defer only implementation details that do not change the model shape

## Exit Criteria

- The Step 4 scope and tasks are documented clearly
- The detailed model design exists in [docs/design/data-model.md](/Users/iamce/dev/electric/turnover/docs/design/data-model.md)
- The major V1 model decisions are documented
- The model is specific enough to guide screen and service implementation
