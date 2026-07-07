# Medical System Design for MIMIC-IV Clinical Database

A database system design project built around the **MIMIC-IV clinical database**, focusing on scalable healthcare data management, database architecture, and clinical decision support.

This project explores how a real-world medical database can be modeled, governed, and optimized to support high-volume healthcare workloads while maintaining data integrity, privacy, and performance.

---

## Overview

Using the **MIMIC-IV** intensive care dataset, this project designs a complete medical data platform that includes:

- Relational database schema design
- NoSQL document model
- Data governance and privacy considerations
- Clinical use case analysis
- Query optimization
- Relational algebra logical plans
- Indexing and caching strategies
- Scalability for large-scale hospital databases

The project demonstrates how database design decisions influence query performance, consistency, scalability, and usability in healthcare applications.

---

## Dataset

This project is based on the **MIMIC-IV Clinical Database**, an anonymized electronic health record dataset developed by MIT for clinical research.

The demo dataset preserves the original schema while containing a subset of patient records suitable for experimentation and database design.

Typical users include researchers, clinicians, and healthcare data scientists interested in predictive modeling, operational analytics, and healthcare system optimization.

---

## Features

### Relational Database Design

- Entity-Relationship (ER) modeling
- Normalized relational schema
- ACID-compliant database design
- Patient-centric partitioning strategy

### NoSQL Design

- Document-oriented schema
- Embedded patient records
- Reduced cross-document joins
- Optimized patient-level retrieval

### Data Governance

- HIPAA compliance considerations
- Patient anonymization
- Identifier removal
- Date shifting
- Access control
- Re-identification risk analysis

### Query Optimization

- SQL query optimization
- Relational algebra trees
- Predicate pushdown
- Composite indexing
- Sparse indexing
- Caching strategies

---

## Clinical Use Cases

This system supports several real-world healthcare applications:

1. Medication Administration Safety
2. ICU Early Warning & Length-of-Stay Prediction
3. Hospital Utilization & Discharge Planning
4. Hospital Flow & Transfer Bottleneck Analysis

Each use case includes workload characteristics, query frequency, expected outputs, and database optimization strategies.

---

## Repository Structure

```text
medical-system-design/
│
├── README.md
├── ER diagram.png
├── Updated RA Tree.png
├── Naive RA Tree.png
├── queries.md
├── Use Cases.md
├── Use Cases (context)/
│   ├── Database/
│   ├── Data/
│   └── README.md
│
├── Data Governance Analysis.docx
├── Indices and Caching Structures.docx
└── Query-ous Clinicians Presentation - Data514.pptx
```

---

## Technologies

- SQL
- Relational Database Design
- NoSQL
- MIMIC-IV
- Database Systems
- Query Optimization
- Data Governance

---

## Team

- Owen Guo
- Roxanne Dimadi
- Ian Chang
- Daniel Yan
- Juan Pablo Reyes Martinez
- Henry Shi

---

## Disclaimer

This repository was developed as an academic database systems project.

The included MIMIC-IV demo dataset follows the licensing and usage requirements of the original MIMIC project.
