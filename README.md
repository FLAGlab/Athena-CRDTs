# Athena-CRDTs

Formal verification of Conflict-free Replicated Data Types (CRDTs) using the Athena proof language.

## Overview

This repository contains formally verified implementations of several CRDTs, including:

- **G-Counter**: Grow-only counter
- **PN-Counter**: Positive-negative counter
- **G-Set**: Grow-only set
- **2P-Set**: Two-phase set
- **LWW-Register**: Last-write-wins register
- **OR-Set**: Observed-remove set

Each CRDT is proven to satisfy semilattice properties (commutativity, associativity, idempotence) and CRDT-specific behavioral properties.

## Structure

- `src/framework/` - Core semilattice theory and verification framework
- `src/crdts/` - CRDT specifications and formal proofs
- `src/demos/` - Example usage scenarios
- `thesis/` - Master's thesis documenting the formal verification approach

## Requirements

- Athena proof assistant - [Installation instructions](https://github.com/AthenaFoundation/athena/wiki/Athena-Installation-Instructions)
